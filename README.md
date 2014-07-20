Blackbit
=========

BlackBit is a simple exchange to allow users to quickly convert Blackcoin to Bitcoin.

Configuring and Starting
-------------

You will need MongoDB, Redis, Blackcoin and Bitcoin for Blackbit to work.

To install the application you must go through the application and copy the sample files to create the required configuration files. 

For example

    cp config/application.yml.sample config/application.yml
    cp config/coins.yml.sample config/coins.yml

Use the start.sh script in the root directory to start the rails program and sidekiq scheduler. 


Credits
-------

Blackwave Labs - blackwavelabs.com

If you use this software you can donate to the following addresses:

Blackcoin: B98Z9DEnTtbYMWZF33iPKjF2LqQa1QUbvq

Bitcoin:   1Q9penuDUUbkt5eDtwgHfZs5A26PHZGuy3


License
-------

Blackbit - Simple Blackcoin to Bitcoin Exchange
Copyright (C) 2014 Blackwave Labs

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
