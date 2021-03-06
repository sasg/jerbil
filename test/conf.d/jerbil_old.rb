# directory used to store the daemons pid to assist in stopping reluctant servers
pid_dir "/var/run/jerbil"

# Set the default environment for service commands etc.
# 
# Can be one of :prod, :test, :dev
environment :prod

# Number of log files to retain at any moment
#log_rotation 2

# Location for Jellog (logging utility) to save log files
log_dir "/var/log/jerbil"

# Size of a log file (in MB) before switching to the next log
#log_length 1

# Controls the amount of logging done by Jellog
# 
#  * :system - standard message, plus log to syslog
#  * :verbose - more generous logging to help resolve problems
#  * :debug - usually used only for resolving problems during development
# 
log_level :debug


# private key file used to authenticate privileged users
key_dir "/var/run/jerbil" 

# Provide a timeout when searching for jerbil servers on the net. Depending on the size of the net mask
# this timeout may make the search long. The default should work in most cases
scan_timeout 0.1

# A valid IPv4 address for the LAN on which the servers will operate.
# Note that the broker uses this address to search for all servers.
# Therefore a large range will take a long time to search. Set the net_mask to limit this.
net_address "192.168.0.1"

# A secret key available to all Jerbil Servers and used to authenticate the inital registration.
# If security is an issue, ensure that this config file is readable only be trusted users
#
# Generate a new secret with something like: openssl genrsa -des3 and paste a line into here
secret "hK78l/z1mIDBOs+/Qx2q7k5beExChmdc3tpw81qTBNLmcQknRrY93oHzIAd3DNo2"

# A valid netmask for the hosts to search using the above net address. This should be
# between 24 (a class C network) and 30, beyound which its not much of a network. If you only have a few
net_mask 26
