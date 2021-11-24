docker-compose -f docker-compose.image.yml build
docker tag truekaso/backend registry.digitalocean.com/truekaso/backend
docker push registry.digitalocean.com/truekaso/backend
