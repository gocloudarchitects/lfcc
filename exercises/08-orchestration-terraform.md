# Orchestration: Terraform

## Installing Terraform

1. Install Terraform. This can be either:
   - On the OpenStack lab
   - On your personal machine (consider using the official Docker container)

2. Stop the docker registry, and deploy the same registry using the [Docker provider for Terraform](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
   
   **HINT:** You can look ahead at example files for the following projects, or even wait until after you've covered some other Terraform exercises to do this exercise.

## Creating OpenStack Admin Resources

1. Create the resources using the provided files.

2. Make some small changes to the configuration (refer to [the documentation](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)), and apply again without destroying.  What resources get destroyed?  What resources simply update?

## Creating OpenStack Tenant Resources

1. Create the resources with the provided files. Instead of using `terraform apply`, use `terraform plan`, and then apply the plan.

2. Choose a tenant and create the following deployment:
   - A network attached to the tenant's router
   - A private network with DHCP
   - A new keypair
     - For an extra challenge, add the `local` provider with the `local_file` resource for the public key, and the `local_sensitive_file` resource for the private key
   - 2 VMs
     - using cirros disk image and smallest available flavor
     - attach a floating IP to one
     - attach a volume to the other
   - Any outputs that you would like to see on creation.

   When complete, you should be able to ssh into the floating IP to access the primary VM. You can `scp` the private key to this VM and use it to access the other.  If you're having issues with connectivity from your environment, you can log in to the VM through the web console.

   **HINT 1:** There are lots of pitfalls, build your template buy designing one resource, and then applying. Occasionally, destroy and reapply fresh.

   **HINT 2:** the `user-data.sh` script should be a standard bash script.

   **HINT 3:** you will either need to use data sources to search for some of the inputs (preferred), or poll the resources using the openstack cli or `terraform state list` and `terraform state show` commands 


## Combining Projects as Modules

1. Destroy your previous resources by going to the previous project directories and running `terraform destroy`

2. Generate the resources with the modularized project

3. Add the tenant resources from the tenant resources exercise as a module.  Instead of using data sources, use the resources created by the other modules.

4. If you wish to continue learning Terraform, you can visit their [documentation](https://www.terraform.io/language) or their [training](https://learn.hashicorp.com/terraform). AWS, GCP, and Azure all offer free tiers or free trials, and you can use that free access to learn the Terraform modules.
   - Use very small instances and as many "free-tier" options as possible
   - Be careful! Make sure you know how to track and delete created resources, or you could get a bill. Ideally, set up a quota with alarms so you will get an email if you go over a set budget


# ANSWERS

## Creating OpenStack Admin Resources

There are any number of answers:
- Change resource names 
- Change quotas
- Change subnet CIDR
- Add a variable to a resource

Some changes only update the resources. Others will trigger a deletion and recreation. 

## Creating OpenStack Tenant Resources

See the template at `files/tenant-terraform-example`

Of note:

1. Data blocks: see how they query existing resources

2. The `depends_on` special block for the VMs: Like much orchestration, terraform creates resources in parallel except where items explicitly depend on one another. Since there is no reference to the required subnets in the VM definition, you have to explicitly set a dependency.

3. The `local` provider: I can call it later in the template, it doesn't need to be at the beginning. The local file resource can also use the `templatefile` module to generate more complex files, but in this case it's not necessary.

4. The `instance_ips` output block

   ```ruby
   output "instance_ips" {
     value = {
       for index, item in openstack_compute_instance_v2.acme: item.name => item.network[*].fixed_ip_v4
     }
   }
   ```

   Note the `index, item` are arbitrary names that mean `key, value` as it iterates over the resource. Since I'm creating these VMs with a `count`, the key is the index and the value is the object definition. If you poll the resource with `terraform state show openstack_compute_instance_v2.acme[0]` you will see the object definition, and see how I'm extracting the desired info.


## Combining Projects as Modules

There are many possible solutions to this task