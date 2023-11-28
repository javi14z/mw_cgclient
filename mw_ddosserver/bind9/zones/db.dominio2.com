$TTL    604800
@       IN      SOA     dominio2.com. admin.dominio2.com. (
                        2023112701  ; Serial
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL
;
@       IN      NS      ns1.dominio2.com.
@       IN      A       127.0.0.2
ns1     IN      A       127.0.0.2
