for container in $(docker ps -q); do
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container)
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    echo "Container Name: $name, IP: $ip"
done
