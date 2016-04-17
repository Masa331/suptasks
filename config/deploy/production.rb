server '52.58.103.140', user: 'ubuntu', roles: %w{web app db}
set :ssh_options, {
 keys: %w(/home/masa331/.ssh/aws2.pem)
}
