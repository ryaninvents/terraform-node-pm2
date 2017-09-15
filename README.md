# terraform-node-pm2

Make sure your SSH key is saved as `~/.ssh/$IAM_KEY_NAME.pem` and has the correct permissions (400).

## Deploying

Copy `config/terraform/backend/sample.tfvars` to `config/terraform/backend.tfvars` and edit before running these commands.

```bash
cd config/terraform
terraform init -backend-config=backend.tfvars
echo "ssh-key = \"$IAM_KEY_NAME\"" > terraform.tfvars
terraform apply
```

## Verifying

Still in the `config/terraform` directory, run `terraform output http-service`. This will output a web address. Visit that address and you should see the "Hello world" message.

Then, SSH into your instance (username `centos`, IP from the web address, use the same key that's been added) and reboot it. It'll take a few minutes, but it should restart the HTTP server once the instance is back online.

## Caveats

If you run this configuration more than once, it might cause the instance to attempt to run multiple copies of the HTTP server on the same port, which it can't do. I'm working on that.
