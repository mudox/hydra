# Developing Environments

Basic environments

**OS_ACTIVITY_DT_MODE**: Only value `NO`, suppres all internal logging generatee by Xcode.

  __Caution__: this would also disable traceback dump when an expection is raised.

Stubbing environments

Following are flag environments, their presence denote `true`, absence denote
`fasle`.

**STUB_TREND_SERVICE**, **STUB_CREDENTIAL_SERVICE**
 
Enumerator environments which take its value as a single string.

**STUB_LANGUAGES_SERVCIE** Possible values: *loading*, *value*, *error*