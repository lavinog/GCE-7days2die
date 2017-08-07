#! /bin/bash
# Updates 7 days to die server on a linux server.
# Source can be found at https://github.com/lavinog/GCE-7days2die
#
# Following Google's bash style guide:
# https://google.github.io/styleguide/shell.xml
#######################################
# Main
#######################################
main(){
  . common_functions.sh
  do_update
}
main
