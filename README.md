    Zip Cracker PS2 Compatible
                                          
----------------------------------------------------------------------------------------------------------------------

You can crack password protected zip files with this script. Please follow the instructions below.

Before running this script make sure that execution-policy is not set to restricted.
`Set-ExecutionPolicy unrestricted`

There are 2 types of usage. You can check them below:

----------------------------------------------------------------------------------------------------------------------

1) `./zipPasswordCracker.ps1 -help h`

This command will show you parameters and some usage examples.


Screenshot: ![alt text](screenShots/help.png)


----------------------------------------------------------------------------------------------------------------------

2) `./zipPasswordCracker.ps1 -dictionaryFile dictionary.txt -zipFile example.7z -mode c`

[-dictionaryPath] argument is the path of the dictionary file.

[-dictionaryFile] argument is the name of the dictionary file.

Either `-dictionaryPath` or `-dictionaryFile` should be given.

[-zipPath] argument is the path of the password protected zip file.

[-zipFile] argument is the name of the password protected zip file.

Either `-zipPath` or `-zipFile` should be given.

[-mode] argument is the option whether script extract the zip or not if it can crack the password. `e` for extract `c` for test

You can use __example.7z__ and __dictionary.txt__ files to try or you can download different dictionaries from [here](https://apasscracker.com/dictionaries/) or [here](http://www.zip-password-cracker.com/dictionaries.html).
The password of given __example.7z__ is `123456`

Screenshot: ![alt text](screenShots/example.png)

----------------------------------------------------------------------------------------------------------------------