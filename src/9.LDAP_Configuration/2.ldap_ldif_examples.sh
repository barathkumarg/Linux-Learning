#!/bin/bash

################################################################################
# LDAP User & Group Management - LDIF Examples
# LDIF = LDAP Data Interchange Format
# This file shows how to ADD, MODIFY, and DELETE users/groups in LDAP
# 
# Production-ready examples explained step-by-step
################################################################################

# =============================================================================
# UNDERSTANDING LDIF FORMAT
# =============================================================================

# LDIF is how you communicate with LDAP server to manage data
# It's a text format with specific rules

# Basic LDIF structure:
# dn: uid=alice,ou=people,dc=example,dc=com      <- Address of object
# uid: alice                                        <- Attribute
# cn: Alice Smith                                   <- Attribute  
# mail: alice@example.com                          <- Attribute
# uidNumber: 5001                                   <- Attribute
# gidNumber: 5000                                   <- Attribute
# objectClass: inetOrgPerson                        <- Attribute (type)
# objectClass: posixAccount                         <- Attribute (type)
# etc.
#
# Blank line signals end of entry

# =============================================================================
# EXAMPLE 1: ADD A NEW USER TO LDAP
# =============================================================================

# Create a file: new-user-alice.ldif

cat > /tmp/new-user-alice.ldif << 'EOF'
# Add Alice Smith - new employee
# dn = Distinguished Name (full path in directory)
# uid = username (like in /etc/passwd)
# objectClass = type of object (inetOrgPerson, posixAccount, etc.)

dn: uid=alice,ou=people,dc=example,dc=com
uid: alice
cn: Alice Smith
sn: Smith
givenName: Alice
mail: alice@example.com
userPassword: {SSHA}WP0+cyKmryblj6+DQCHbGFEW6YJIHyAP    # Password (encrypted)
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
userPassword: {crypt}$6$Hs...encrypted_hash...        # Linux crypt hash
uidNumber: 5001         # User ID (must be unique, >= 5000 for regular users)
gidNumber: 5000         # Primary Group ID
homeDirectory: /home/alice
loginShell: /bin/bash
description: Software Engineer

EOF

# Add this user to LDAP:
ldapadd -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/new-user-alice.ldif

# -x: Simple authentication
# -H: LDAP server URI
# -D: Bind DN (admin account)
# -w: Bind password
# -f: File with LDIF data

# Expected output:
# adding new entry "uid=alice,ou=people,dc=example,dc=com"

# =============================================================================
# EXAMPLE 2: ADD MULTIPLE USERS AT ONCE  (PRODUCTION EXAMPLE)
# =============================================================================

# Real company scenario: Onboarding 5 new engineers

cat > /tmp/new-employees.ldif << 'EOF'
# New Employees - Batch Add
# Company: TechCorp
# Department: Engineering
# Note: Each entry separated by blank line

dn: uid=john.doe,ou=people,dc=example,dc=com
uid: john.doe
cn: John Doe
sn: Doe
givenName: John
mail: john.doe@example.com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
userPassword: {crypt}$6$randomhash123456789
uidNumber: 5010
gidNumber: 5000
homeDirectory: /home/john.doe
loginShell: /bin/bash
description: Senior Engineer
title: Software Engineer
department: Engineering

dn: uid=jane.smith,ou=people,dc=example,dc=com
uid: jane.smith
cn: Jane Smith
sn: Smith
givenName: Jane
mail: jane.smith@example.com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
userPassword: {crypt}$6$randomhash987654321
uidNumber: 5011
gidNumber: 5000
homeDirectory: /home/jane.smith
loginShell: /bin/bash
description: DevOps Engineer
title: DevOps Engineer
department: Infrastructure

dn: uid=bob.wilson,ou=people,dc=example,dc=com
uid: bob.wilson
cn: Bob Wilson
sn: Wilson
givenName: Bob
mail: bob.wilson@example.com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
userPassword: {crypt}$6$randomhashbobwilson
uidNumber: 5012
gidNumber: 5000
homeDirectory: /home/bob.wilson
loginShell: /bin/bash
description: QA Engineer
title: QA Engineer
department: Quality Assurance

EOF

# Add all users at once:
ldapadd -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/new-employees.ldif

# All 3 users added to LDAP in one command!
# They're immediately available across all servers using LDAP

# =============================================================================
# EXAMPLE 3: MODIFY EXISTING USER (CHANGE EMAIL, PHONE, etc.)
# =============================================================================

# User alice changed email address
# Create a modify file: modify-alice-email.ldif

cat > /tmp/modify-alice-email.ldif << 'EOF'
# Modify Alice's email address
# changetype: modify tells LDAP this is a modification
# replace: specifies what to change

dn: uid=alice,ou=people,dc=example,dc=com
changetype: modify
replace: mail
mail: alice.newemail@example.com
-

EOF

# Apply modification:
ldapmodify -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/modify-alice-email.ldif

# Expected output:
# modifying entry "uid=alice,ou=people,dc=example,dc=com"

# Now check if change applied:
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "dc=example,dc=com" \
  "uid=alice" \
  mail

# Should show: mail: alice.newemail@example.com

# =============================================================================
# EXAMPLE 4: DELETE A USER FROM LDAP
# =============================================================================

# Alice left the company - remove her account

ldapdelete -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  "uid=alice,ou=people,dc=example,dc=com"

# Expected output:
# deleting entry "uid=alice,ou=people,dc=example,dc=com"

# After this:
# - alice can't login on ANY server using LDAP
# - All 50 servers immediately enforce this
# - No need to delete from 50 different /etc/passwd files!

# =============================================================================
# EXAMPLE 5: CREATE GROUPS AND ADD MEMBERS
# =============================================================================

# Create groups in LDAP
# Group for administrators

cat > /tmp/add-groups.ldif << 'EOF'
# Create Groups
# ou=groups is where groups live

dn: cn=admins,ou=groups,dc=example,dc=com
cn: admins
objectClass: posixGroup
objectClass: top
gidNumber: 5001
description: System Administrators
memberUid: john.doe
memberUid: jane.smith

-

# Engineers group
dn: cn=developers,ou=groups,dc=example,dc=com
cn: developers
objectClass: posixGroup
objectClass: top
gidNumber: 5002
description: Software Development Team
memberUid: bob.wilson
memberUid: alice

-

# Support staff group
dn: cn=support,ou=groups,dc=example,dc=com
cn: support
objectClass: posixGroup
objectClass: top
gidNumber: 5003
description: Technical Support Team
memberUid: alice

EOF

# Add groups to LDAP:
ldapadd -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/add-groups.ldif

# Now verify groups:
getent group admins
# Output: admins:x:5001:john.doe,jane.smith

getent group developers
# Output: developers:x:5002:bob.wilson,alice

# =============================================================================
# EXAMPLE 6: ADD MEMBER TO EXISTING GROUP
# =============================================================================

# John doe joins the developers group

cat > /tmp/add-to-group.ldif << 'EOF'
dn: cn=developers,ou=groups,dc=example,dc=com
changetype: modify
add: memberUid
memberUid: john.doe
-

EOF

ldapmodify -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/add-to-group.ldif

# Verify:
getent group developers
# Output: developers:x:5002:bob.wilson,alice,john.doe

# =============================================================================
# EXAMPLE 7: REAL PRODUCTION WORKFLOW
# =============================================================================

# Scenario: New employee onboarding process

# Step 1: Create LDIF with employee info

cat > /tmp/new-employee-template.ldif << 'EOF'
# NEW EMPLOYEE ONBOARDING
# Date: 2024-01-15
# HR Reference: EMP-2024-001234

dn: uid=sarah.jones,ou=people,dc=example,dc=com
uid: sarah.jones
cn: Sarah Jones
sn: Jones
givenName: Sarah
mail: sarah.jones@example.com
# Generate password hash: slappasswd -h {SSHA} -s "InitialPassword123!"
userPassword: {SSHA}WP0+cyKmryblj6+DQCHbGFEW6YJIHyAP
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uidNumber: 5020
gidNumber: 5000
homeDirectory: /home/sarah.jones
loginShell: /bin/bash
description: Data Scientist
title: Data Scientist
department: Data Science
telephoneNumber: +1-555-0123
o: TechCorp
l: San Francisco

EOF

# Step 2: Add to LDAP
ldapadd -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/new-employee-template.ldif

# Step 3: Add to appropriate groups (Data Science team, all employees)
cat > /tmp/add-to-groups.ldif << 'EOF'
dn: cn=data-science,ou=groups,dc=example,dc=com
changetype: modify
add: memberUid
memberUid: sarah.jones
-

dn: cn=all-employees,ou=groups,dc=example,dc=com
changetype: modify
add: memberUid
memberUid: sarah.jones
-

EOF

ldapmodify -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/add-to-groups.ldif

# Step 4: Verify (from any server with LDAP client)
getent passwd sarah.jones
# sarah.jones:x:5020:5000:Sarah Jones:/home/sarah.jones:/bin/bash

id sarah.jones
# uid=5020(sarah.jones) gid=5000(developers) groups=5000(developers),5002(data-science),5003(all-employees)

# Step 5: New employee can login from ANY server
ssh sarah.jones@server1.company.com
ssh sarah.jones@server2.company.com
ssh sarah.jones@server50.company.com
# Works on all 50 servers! No manual user additions needed!

# =============================================================================
# EXAMPLE 8: BATCH EMPLOYEE REMOVAL (OFFBOARDING)
# =============================================================================

# Company annual downsizing: Remove 3 employees

# Method 1: Create LDIF with delete operations

cat > /tmp/offboard-employees.ldif << 'EOF'
# Remove employees who left company
# Effective: 2024-03-31

dn: uid=old.employee1,ou=people,dc=example,dc=com
changetype: delete

-

dn: uid=old.employee2,ou=people,dc=example,dc=com
changetype: delete

-

dn: uid=old.employee3,ou=people,dc=example,dc=com
changetype: delete

EOF

ldapmodify -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/offboard-employees.ldif

# All 3 employees immediately denied access across entire infrastructure!

# =============================================================================
# EXAMPLE 9: COMMON LDIF OPERATIONS REFERENCE
# =============================================================================

# OPERATION 1: Replace attribute
cat > /tmp/ldif-replace.ldif << 'EOF'
dn: uid=alice,ou=people,dc=example,dc=com
changetype: modify
replace: mail
mail: alice.new@example.com
-
EOF

# OPERATION 2: Add attribute (useful for multi-valued attributes)
cat > /tmp/ldif-add.ldif << 'EOF'
dn: uid=alice,ou=people,dc=example,dc=com
changetype: modify
add: objectClass
objectClass: shadowAccount
-
add: telephoneNumber
telephoneNumber: +1-555-0123
-
EOF

# OPERATION 3: Delete attribute
cat > /tmp/ldif-delete.ldif << 'EOF'
dn: uid=alice,ou=people,dc=example,dc=com
changetype: modify
delete: telephoneNumber
-
EOF

# OPERATION 4: Delete entire entry
cat > /tmp/ldif-delete-entry.ldif << 'EOF'
dn: uid=alice,ou=people,dc=example,dc=com
changetype: delete
EOF

# =============================================================================
# HELPFUL COMMANDS FOR MANAGING LDIF DATA
# =============================================================================

# Generate password hash for LDIF (use in userPassword field)
slappasswd -h {SSHA} -s "YourPassword123"
# Output: {SSHA}WP0+cyKmryblj6+DQCHbGFEW6YJIHyAP (paste this in LDIF)

# ─────────────────────────────────────────────────────────────────────────

# Search and export users to LDIF
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -b "ou=people,dc=example,dc=com" \
  > /tmp/backup-users.ldif

# This backs up all users

# ─────────────────────────────────────────────────────────────────────────

# Validate LDIF file before applying
ldapmodify -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/changes.ldif \
  -n  # -n = "dry-run" mode (show what would happen without doing it)

# ─────────────────────────────────────────────────────────────────────────

# Count total users in LDAP
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "ou=people,dc=example,dc=com" \
  -s sub \
  "(objectClass=posixAccount)" \
  | grep "^dn:" | wc -l

# ─────────────────────────────────────────────────────────────────────────

# Count users in specific group
ldapsearch -x \
  -H ldap://10.0.0.101 \
  -b "cn=admins,ou=groups,dc=example,dc=com" \
  memberUid \
  | grep "^memberUid:" | wc -l

# =============================================================================
# TROUBLESHOOTING LDIF
# =============================================================================

# Error: "Invalid DN syntax"
# Cause: DN format incorrect
# Fix: Check: dn: uid=alice,ou=people,dc=example,dc=com
#      Should be exact format (no extra spaces, proper commas)

# ─────────────────────────────────────────────────────────────────────────

# Error: "No such object"
# Cause: Parent DN doesn't exist (ou=people not created)
# Fix: Create organizational units first:

cat > /tmp/create-ous.ldif << 'EOF'
dn: ou=people,dc=example,dc=com
objectClass: organizationalUnit
ou: people

-

dn: ou=groups,dc=example,dc=com
objectClass: organizationalUnit
ou: groups

EOF

ldapadd -x \
  -H ldap://10.0.0.101 \
  -D "cn=admin,dc=example,dc=com" \
  -w "admin_password" \
  -f /tmp/create-ous.ldif

# ─────────────────────────────────────────────────────────────────────────

# Error: "Already exists"
# Cause: Trying to add user that already exists
# Solution: 
#   1. Check if user exists: ldapsearch -x ... "uid=alice"
#   2. Either modify existing or use different uid

# ─────────────────────────────────────────────────────────────────────────

# Error: "Insufficient access rights"
# Cause: Bind DN doesn't have permission
# Fix: Use admin account with proper permissions
#      -D "cn=admin,dc=example,dc=com"

################################################################################
# KEY TAKEAWAYS
################################################################################

# LDIF = Text format for LDAP operations
# Three main operations:
#   1. ADD    - ldapadd command      (new users/groups)
#   2. MODIFY - ldapmodify command   (change existing)
#   3. DELETE - ldapdelete command   (remove users/groups)

# Benefits of LDAP:
#   - One user account per person (not replicated across servers)
#   - Changes apply instantly across all servers
#   - Centralized administration
#   - Scalable to 1000s of users

# Production workflow:
#   1. Create LDIF file
#   2. Test against test LDAP server
#   3. Apply to production LDAP
#   4. Verify with getent passwd/group
#   5. Test user login

################################################################################
# END OF LDIF EXAMPLES
################################################################################

