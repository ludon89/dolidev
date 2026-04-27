#!/bin/bash

# Test presence of file
if [ ! -f ".run-phpstan" ]; then
	echo "Skipping PHPStan (file .run-phpstan missing)"
	exit 0
fi

if [ ! -f "~/vendor/bin/phpstan" ]; then
	echo "Skipping PHPStan (file ~/vendor/bin/phpstan missing)"
	exit 0
fi

echo "Running PHPStan"
~/vendor/bin/phpstan analyz  e

exit 1;
