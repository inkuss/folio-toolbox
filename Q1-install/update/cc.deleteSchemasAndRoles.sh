#!/bin/bash
# Thanks to Chris Creswell at Lehigh

read -p "Enter tenant id: " tenant_id
echo "tenant id: $tenant_id"

# When okapi enables a module for a tenant, it tries to create the database
# and role for that tenant-module schema.  If we're enabling modules again
# on a system where it's already been done once as part of a rebuild,
# this won't work.  So, this script just drops the existing schemas and
# roles that start with "${tenant_id}_*".

roles=`su postgres bash -c "psql postgres postgres -c 'select rolname from pg_roles'"`
#echo $roles
for role in `echo $roles`; do
    echo $role
    if [[ $role == ${tenant_id}_* ]] ; then
        echo "Dropping role $role";
        `su postgres bash -c "psql folio postgres -c 'drop schema $role cascade'"`
        `su postgres bash -c "psql postgres postgres -c 'drop role $role'"`
    fi
done
