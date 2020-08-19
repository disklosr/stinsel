# A helper script to deploy a single stack to a specific server
# Usage: ./deploy.sh target_server stack_id

target=$1
shift
stackid=$1
shift
ansible-playbook stacks/$stackid/test.yml --extra-vars "target=$target" $@