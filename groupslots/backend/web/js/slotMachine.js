'use strict';

/////////////////////////////////////////////////////////////////////////////////// GLOBAL VARIABLES
var audioMimeTypes,
    betField,
    moneyField,
    createsoundbite,
    spinsound,
    playButton,
    playSlots,
    winsound;
var resultNums = [];


var card_id = '1234';
var group_id = '1';


/////////////////////////////////////////////////////////////////////////////////// GLOBAL FUNCTIONS
createsoundbite = function(sound) {
    // Define local variables
    var html5audio,
        i,
        sourceel;
    
    html5audio = document.createElement('audio');
    if(html5audio.canPlayType) { //check support for HTML5 audio
        for(i=0; i<arguments.length; i++) {
            sourceel = document.createElement('source');
            sourceel.setAttribute('src', arguments[i]);
            if(arguments[i].match(/\.(\w+)$/i)) {
                sourceel.setAttribute('type', audioMimeTypes[RegExp.$1]);
            }
            html5audio.appendChild(sourceel);
        }
        html5audio.load();
        html5audio.playclip = function() {
            html5audio.pause();
            html5audio.currentTime = 0;
            html5audio.play();
        };
        
        return html5audio;
    } else {
        return {
            playclip : function() {
                window.alert("Your browser doesn't support HTML5 audio");
            }
        };
    }
};

playSlots = function() {
    // Local variable definitions
    var betAmount = parseInt(betField.value, 10),
        currentList,
        currentMoney = parseInt(moneyField.value, 10),
        finishedCount = 0,
        firstItem,
        listHeight,
        lowerSpeed,
        myList,
        sevenCount = 0,
        slotNumber = $('.slot').length,
        spinEm,
        spinSpeed = 1100;
    
    currentMoney -= betAmount;
    moneyField.value = currentMoney;
    spinsound.playclip();
    
    spinEm = function(i, list, firstItem, myList, listHeight) {
        list.
            css('margin-top', listHeight).
            animate({'margin-top':'0px'}, spinSpeed, 'linear', function() {
                lowerSpeed(i, list, listHeight);
            });
    };
    
    lowerSpeed = function(i, currentList, listHeight) {
        // Define local variables
        var checkWinner,
            finalPos,
            finalSpeed,
            group_id,
            winAmount;
        
        if ( spinSpeed < 1000 ) {
            spinEm(currentList, firstItem, myList, listHeight);
        } else {
            checkWinner = function(num) {
                finishedCount++;
                if (num === 1) {
                    sevenCount++;
                }
                if (slotNumber > $('.slot').length) {
                    slotNumber = $('.slot').length;
                }
                if (finishedCount === slotNumber) {
                    winAmount = 0;
                    if (sevenCount === 1) {
                        winAmount = betAmount * 5;
                    } else if (sevenCount === 2) {
                        winAmount = betAmount * 40;
                    } else if (sevenCount >= 3) {
                        winAmount = betAmount * 300;
                    }
                    if (winAmount > 0) {
                        // you done won
                        winsound.playclip();
                        currentMoney += winAmount;
                        moneyField.value = currentMoney;

                        if (winAmount > 500) {
                            winAmount = 500;
                        }
                        
                        // register win
                        $.post("http://groupslots.local.elephantventures.com:8000/api/v1/win", {amount: winAmount});

                        // Report this user's winnings
                        // fbExecuteAction({
                        //     sAction : 'registerPoints',
                        //     oAjaxSettings : {
                        //         data : {
                        //             amount : winAmount
                        //             // cardId : card_id,
                        //             // machine_id : $('#machine_id').val()
                        //         },
                        //         success : function(data) {
                        //             // HOORAY!!!
                        //             window.alert('You won $' + winAmount.toLocaleString() + '!\n\n'); //+data);
                        //         }
                        //     }
                        // });
                    }
                    
                    // Allow the "Play" button to be clicked again
                    playButton.classList.remove('disabled');
                    playButton.disabled = false;
                }
            };
            
            // Grab a random number
            var myNum = Math.floor((Math.random() * (myList.length-4)) + 1);

            if($("#win_always").attr('checked') == 'checked') {
                myNum = 1;
            }
            resultNums[i] = myNum;
            
            finalPos = - ( (firstItem.outerHeight() * myNum)-firstItem.outerHeight() );
            finalSpeed = ( (spinSpeed * 0.5) * (myList.length-1) ) / myNum;
            
            currentList.
                css('margin-top', listHeight).
                animate({'margin-top':finalPos}, finalSpeed, 'swing', function() {
                    checkWinner(resultNums[i]);
                });
        }
    };
    
    var i = 0;
    $('.slot').each(function() {
        currentList = $(this);
        firstItem = currentList.children('li:first');
        myList = currentList.children('li');
        listHeight = -( firstItem.outerHeight() * ( myList.length-1) );

        spinEm(i, currentList, firstItem, myList, listHeight);
        i++;
    });
};





/////////////////////////////////////////////////////////////////////////////// DOCUMENT READY EVENT
document.addEventListener(
    'DOMContentLoaded',
    function() {
        // Cache DOM lookups
        betField = document.getElementById('bet');
        moneyField = document.getElementById('money');
        playButton = document.getElementById('playButton');
        
        // Define list of audio file extensions and their associated MIME types
        audioMimeTypes = {
            mp3 : 'audio/mpeg',
            mp4 : 'audio/mp4',
            ogg : 'audio/ogg',
            wav : 'audio/wav'
        };
        
        // Show the correct logged-in status
        // if(oUser === null) {
            // User is logged-out
            // $('#logged_out').removeClass('hidden');
        // } else {
            // User is logged-in
            $('#card_id_label').text(card_id);
            $('#group_id_label').text(group_id);
            $('#logged_in').removeClass('hidden');
            $('#game').removeClass('hidden');
        // }
        
        //Initialize two sound clips with 1 fallback file each:
        spinsound = createsoundbite('audio/spin.mp3');
        winsound = createsoundbite('audio/win.mp3');
        
        // Slot machine number rotators
        $('.slot').each(function() {
            var currentList = $(this),
                firstItem = currentList.children('li:first'),
                listHeight,
                myList = currentList.children('li');
            
            currentList.css('margin-top', listHeight);
            listHeight = -( firstItem.outerHeight() * ( myList.length-1) );
        });
        
        // playButton click listener
        playButton.addEventListener(
            'click',
            function() {
                if(parseInt(betField.value, 10) <= parseInt(moneyField.value, 10)) {
                    playSlots();
                    this.disabled = true;
                    this.classList.add('disabled');
                } else {
                    window.alert('You need more money!');
                }
            },
            false
        );
        
        // Login form event listeners
        $("#card_id").keyup(function(evt) {
            if(evt.keyCode === 13) {
                $("#login_button").click();
            }
        });
        $('#login_button').click(function() {
            fbExecuteAction({
                sAction : 'login',
                oAjaxSettings : {
                    data : {card_id : $('#card_id').val()},
                    success : function(sResponse) {
                        console.log(sResponse);
                        // if(sResponse === 'ERROR') {
                        //     window.alert('login failed');
                        //     return;
                        // }
                        window.location.reload();
                    }
                }
            });
        });
    },
    false
);