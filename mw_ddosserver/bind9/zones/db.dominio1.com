$TTL    604800
@       IN      SOA     dominio1.com. admin.dominio1.com. (
                        2023112701  ; Serial
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL
;
@       IN      NS      ns1.dominio1.com.
@       IN      A       127.0.0.3
ns1     IN      A       127.0.0.3
