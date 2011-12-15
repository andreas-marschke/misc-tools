define host {
        use             windows-server
        host_name       somebox
        alias           somebox.example.org
        address         192.168.0.33
        hostgroups      windows-servers,nsclients
        parents         firewall
}

