<?php
/*
How to use?
$hString is string you want to hash, probably password.
$hDecode is already hashed string (password). When you use function obscure() to generate hash, you will probably enter it in database. When user wants to log in, you pass plain password with $hString, and hashed password from database in $hDecode.
$hSLength is length of salt. It's caped by method you use to hash, so in case you use sha1, you can pass value 100, but it will still use 40 characters.
$keepLength can be used to cap final output at max characters that hash function gives. In case sha1, hash would give output of 40 characters. If you set $keepLength to '1' final outputted hash would have 40 characters by cutting pieces of hashed password. Why would you want to do it? So that attacker doesn't know it's salted :)
$minhPass - it is usually defined only if you decide to set $keepLength so that you can define minimum amount of characters of hashed password you want to keep. Default is 10. It's used because you can accidentally set, in combination with $keepLength, $hSLength too high which would cause that all characters of hashed password are cut out and leave only salt which would always validate true without regard what password user enters.
$hMethod defines which method you want to use to hash plain text since this function is build using hash(). If you want to use sha512, function will adapt to it.

Quick example:
Hashing a password - obscure ($plain_password);
Validating password - $hashedPassword == obscure ($plain_password, $hashedPassword);

I've been getting few requests to explain how it's used so, this might be little long.

Problems:
1. In most solutions with hash and salt, you were bound to have one extra row in your database that would state, preferably random, salt for that hashed data. If attacker would manage to get drop of your database he would get hashed data and salt that is used with plain data to make it obscure, and then cracking that hashed data would be same as if you didn't add any salt to it.
2. I stumbled upon some functions that would hash data, then input salt into random places in hash and store it in database, but they would still have to write down random parameter used to scramble salt so they could reuse it when validating data. Getting simple database drop wouldn't help much here, but if they would manage to get their hands on obscuring function too, they could easily see what is salt and what hash.

Solutions:
1. Why use extra row to store salt when you can input it in hash. I'm not sure how attackers determine what type of hash are they facing, but I guess it has connection to hash length. In that case, why make attackers job easier and store in database data_hash+salt where they could assume just by it's length it has salt in there.
Reason behind $keepLength. If it's set to 1, strlen of hashed data plus salt would be equal to strlen of hashed data leading attacker to believe there is no salt.
If you leave $keepLength on NULL, strlen of final result would be strlen(used_hash_algorithm)+$hSLength.
$minhPass is there to reserve enough place for string that has to be hashed, so someone using this function wouldn't accidentally delete it by setting too high salt length ($hSLength), for example... if you set it 30000 it will keep working normal.

2. If you think about it, constant, but variable value when making input would be same data that is being input.
In case we're trying to hash password, and have user A with password "notme", password strlen equals to 5, and if we use default parameters of the function, with $keepLength set to 1, process would be:
random salt, hash it, add first 5 characters of hashed_salt at beginning of plain password, add last 5 characters of hashed_salt at end of plain password, hash it. Replace first 5 characters of hashed_password with first 5 character of hashed_salt, do same with last 5 characters of hashed_password, return hashed_password.
In case that string is longer than 10 characters function would use simple mathematics to reduce it to numbers lower than 10, well... lower than number that is stated in $hSLength.
And good thing is that every time user enters correct password it has same length so it's not necessary to write it anywhere.

So what is achieved in the end?
1. Attacker might not know that hash is salted, and you don't have that extra row in your database stating THIS IS SALT FOR THIS HASH.
2. If he does find out that it is, he wouldn't know what is hashed password and what is salt.
3. If he manages to get access to obscure function, only thing that might help him is value of $hSLength, where if $hSLength is set to 10 he would have to crack 10 variations of hashed string since he doesn't know how long password of user he's trying to crack is.
For example first variation would be hashed_password without last 10 characters, second variation would be hashed_password without first character and last 9 characters...
4. Even in case he has enough power to crack all 10 variations, resulting string that he might get doesn't necessarily has to be exactly long as password of original user in which case, attacker fails again because of the way the function manages to get the number of characters to take from the original salt to encapsulate the final string.
*/

/*
The functionning of the Obscure function is pretty simple :
We compute a random string, then produce its hash. Then we grab some of the first and last characters of this hash which constitutes our salt.
Now we invert the order (first characters in the end, and last characters at the beginning) and encapsulate the plain password inside this salt, and then compute the hash (password hash).
We then invert again the order of the salt (so we get back the original order), and encapsulate the password hash inside the salt, so next time we use the Obscure function to verify the hash, the function will be able to get back the salt by decomposing the given hash, and redo the whole operation to get the resulting hash which, if the hash given was right, should be the same as the one input.

This means that $hashedPassword == obscure ($plain_password, $hashedPassword) if ok.

So, most of the function is about filtering and managing the salt, which encapsulates the plain password, and then the final hash (yes, the hash is used two times : once to hash password, and secondly with the hashed password to store the salt along it).
*/

function obscure($hString, $hDecode = NULL, $hSLength = 8, $keepLength = NULL, $minhPass = 8, $hMethod = "sha1")
{
    $hRandomSalt = '';
    
    if ($hDecode == NULL) // If no hashed string is given, we compute one from a random salt (Hashing password mode)
    {
        for ($i = 0; $i<$hsLength; $i++) // Generate a random salt composed of 16 characters (which ASCII code is comprised between 33 and 255)
        {
            $hSalt = rand(33, 255);
            $hRandomSalt .= chr($hSalt);
        }
        $hRandomSalt = hash($hMethod, $hRandomSalt); // Generate a hash from this salt (this hash will itself be used as a salt for the password later)
    }
    else // If a hashed string was given, we use it as the hashed salt for later computation of the hashed password (Verify password mode). Indeed, a hashed password is encapsuled inside the salt, so we just have to cut off the prepended and appended salt to use it to compute the hash of the given password to verify.
    {
        $hRandomSalt = $hDecode;
    }

    // Minimum amount of characters to keep from plain password. It's used because you can accidentally set, in combination with $keepLength, $hSLength too high which would cause that all characters of hashed password are cut out and leave only salt which would always validate true without regard what password user enters.
    if ($keepLength != NULL)
    {
       
        if ($hSLength > (strlen($hRandomSalt) - $minhPass))
        {
            $hSLength = (strlen($hRandomSalt) - $minhPass);
        }
    }
    else if ($hSLength < 0)
    {
        $hSLength = 0;
    }

    // Computing the number of characters to take from the salt to compose the final encapsulating salt
    // This value is totally dependant from the $hString (plain password) length : this means that even if the attacker find a collision, if the password inputted isn't the same length as the original password, it won't validate because it may not be the same salt.
    $hLPosition = strlen($hString);
    while ($hLPosition > $hSLength)
    {
        $hNumber = substr($hLPosition, -1);
       
        $hLPosition = $hLPosition * ($hNumber/10);
    }

    // Computing the two encapsulating salts from the original one contained in $hRandomSalt
    $hLPosition = (integer)$hLPosition; // Number of characters in the beginning of the salt which will really be used as the salt
    $hRPosition = $hSLength - $hLPosition; // Number of characters in the end of the salt...

    $hFSalt = substr($hRandomSalt, 0, $hLPosition); // Get the first characters of the temporary salt
    $hLSalt = substr($hRandomSalt, -$hRPosition, $hRPosition); // Get the last characters of the temporary salt

    // Computing the password hash
    $hPassHash = hash($hMethod, ($hLSalt . $hString . $hFSalt)); // Invert the two resulting salts, and encapsulate the plain password inside, then hash it

    // Slicing the beginning and the end of the hashed password to get a constant length hash, only if $keepLength is set to 1
    if ($keepLength != NULL)
    {
        if ($hSLength != 0)
        {
            if ($hRPosition == 0) // If the password is too short, then $hRPosition is equal to 0, so we can't remove anything at the end, only at the beginning (see below, -$hRPosition would give -0...)
            {
                $hPassHash = substr($hPassHash, $hLPosition);
            }
            else // Else, if the password is long enough, we cut in the middle of the string
            {
                $hPassHash = substr($hPassHash, $hLPosition, -$hRPosition);
            }
        }
    }

    // Return the final password hash, composed of the password hash encapsulated inside the reordered two salts
    // This is how we can retrieve later the salt, which will be reused for calculation to verify if the password is right of false
    return $hFSalt . $hPassHash . $hLSalt;
}
?>