# How to Work with mkit

## Adding a new profile

A profile is a collection of packages. Each package is downloaded and built separately.
Currently there is automatic dependency tracking so all packages 


Example profile:

```bash
profile_uwsgi()
{
 profile_python
 add_run_dep uwsgi
 return $?
}
```
