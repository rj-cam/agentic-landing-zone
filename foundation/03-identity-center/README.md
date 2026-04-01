# 03 - Identity Center

This Terraform layer configures AWS IAM Identity Center (successor to AWS SSO)
for the landing zone organization.

## Permission Sets

| Permission Set       | AWS Managed Policy        | Scope           |
|----------------------|---------------------------|-----------------|
| AdministratorAccess  | AdministratorAccess       | All accounts    |
| DeveloperAccess      | PowerUserAccess           | Non-prod only   |
| ReadOnlyAccess       | ReadOnlyAccess            | All accounts    |

## Local User

A local Identity Center user is created as a reference implementation to
bootstrap initial access. The user is added to an **Administrators** group
which receives the account assignments listed above.

## Production Considerations

For production use, replace the local user with an external identity provider
via SAML 2.0 or OIDC federation (e.g., Azure AD, Okta, Google Workspace).
The permission sets and account assignments remain the same regardless of the
identity source.
