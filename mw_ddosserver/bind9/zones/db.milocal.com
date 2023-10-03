\$TTL    604800
@    IN    SOA     ns1.example.com. admin.example.com. (
                  3        ; Serial
             604800        ; Refresh
              86400        ; Retry
            2419200        ; Expire
             604800 )    ; Negative Cache TTL
;
    IN  NS  ns1.example.com.
    IN  NS  ns2.example.com

; name servers - A records
@                       IN  A   127.0.0.1
ns1.example.com.          IN  A   127.0.0.1
ns2.example.com.          IN  A   127.0.0.1