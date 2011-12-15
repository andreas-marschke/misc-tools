define service {
    use                 generic-service
    host_name           $HOST$
    service_description $DESC$
    check_command       check_nrpe_1arg!$CHECK$
    contact_groups          +oncall
}
