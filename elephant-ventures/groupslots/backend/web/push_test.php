<?php

date_default_timezone_set('America/New_York');

// Using Autoload all classes are loaded on-demand
require_once 'ApnsPHP/Autoload.php';

// Instantiate a new ApnsPHP_Push object
$push = new ApnsPHP_Push(
	ApnsPHP_Abstract::ENVIRONMENT_SANDBOX,
	'certs/Certificates.pem'
);

// Set the Root Certificate Autority to verify the Apple remote peer
$push->setRootCertificationAuthority('certs/entrust_2048_ca.pem');

// Connect to the Apple Push Notification Service
$push->connect();

// Instantiate a new Message with a single recipient (device token)
$message = new ApnsPHP_Message("e1ad0f47e8099211a7dc33a367aaf986e9fb674d02e3ffa5ea5947a10b964420");

// Set a custom identifier. To get back this identifier use the getCustomIdentifier() method
// over a ApnsPHP_Message object retrieved with the getErrors() message.
$message->setCustomIdentifier("-goal-reached");

$message->setBadge(1);

// Set a simple welcome text
$message->setText('Achieved goal!');

// Play the default sound
$message->setSound();

// Set a custom property
$message->setCustomProperty('acme2', array('bang', 'whiz'));

// Set another custom property
$message->setCustomProperty('acme3', array('bing', 'bong'));

// Set the expiry value to 30 seconds
$message->setExpiry(30);

// Add the message to the message queue
$push->add($message);

// Send all messages in the message queue
$push->send();

// Disconnect from the Apple Push Notification Service
$push->disconnect();
