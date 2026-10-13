# Ldap (`symfony/ldap`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when users log in with LDAP or Active Directory passwords, or PHP code must search or change directory entries. It is an LDAP client on top of the PHP LDAP extension. It also checks login passwords with an LDAP bind, and gives roles from LDAP groups. For the login setup, see [Security](security-bundle.md).

**Details:** [../details/ldap.md](../details/ldap.md)

## Why it exists

Organizations often keep user accounts, passwords and groups in an LDAP directory, for example OpenLDAP or Active Directory. The raw PHP LDAP functions return nested arrays and need manual escaping and paging. The package is an object-oriented LDAP client on top of the PHP LDAP extension. It also lets [Security](security-bundle.md) load users from the directory and check passwords with an LDAP bind.

## When to use it

- Log users in with a password that an LDAP server or Active Directory checks.
- Load users and their roles from an LDAP directory.
- Check passwords against LDAP, but load the users from the application database.
- Give roles to users from their LDAP groups, for example from the memberOf or isMemberOf attribute.
- Search an LDAP directory for people, groups or other entries.
- Create, change, rename, move or delete LDAP entries from PHP code.
- Bind to an LDAP server with a DN and a password, or with SASL, in application code or in a command-line script.

## Use it instead of

- `ldap_connect('ldap://dc1.example.com')`, `ldap_set_option()` and `ldap_bind()` in each service -> one `Ldap` service with `ExtLdap\Adapter` options, and `$ldap->bind($dn, $password)`.
- `ldap_search()` plus `ldap_get_entries()` and loops over `$entries[$i]['mail'][0]` with `count` keys -> `$ldap->query($baseDn, $filter, ['filter' => ['mail']])->execute()` and `Entry::getAttribute('mail')`.
- A paged search loop with `LDAP_CONTROL_PAGEDRESULTS` server controls and cookies -> the `pageSize` query option.
- User input in a filter or a DN as plain text (`"(uid=$username)"`), or escaped with `addslashes()` -> `$ldap->escape($username, '', LdapInterface::ESCAPE_FILTER)` or `LdapInterface::ESCAPE_DN`.
- `ldap_add()`, `ldap_modify()`, `ldap_mod_add()`, `ldap_mod_del()`, `ldap_rename()` and `ldap_delete()` with attribute arrays -> the `EntryManager` methods with an `Entry` object.
- `ldap_modify_batch()` with `['attrib' => ..., 'modtype' => ..., 'values' => ...]` arrays -> `applyOperations($dn, [new UpdateOperation(LDAP_MODIFY_BATCH_REPLACE, 'mail', ['a@example.com'])])`.
- A login controller that calls `ldap_bind()` with the submitted password and then logs the user in -> `form_login_ldap`, `json_login_ldap` or `http_basic_ldap` in `security.yaml`.
- A custom `UserProviderInterface` class that searches LDAP for the user name -> the `ldap` user provider.
- Code that splits `memberOf` DNs with `explode(',', ...)` to set roles -> `MemberOfRoles` as the `role_fetcher` service.
