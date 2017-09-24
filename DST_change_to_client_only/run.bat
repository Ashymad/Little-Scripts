@echo off
::Ver 1.0
::sfk sel . modinfo.lua +run -yes "sfk filt $file -where client_only_mod -rep _false_true_ -write -yes || sfk ftext $file client_only_mod -justrc && echo(>>$file && echo(client_only_mod = true>>$file"

::Ver 2.0
::sfk select . modinfo.lua +perline -yes "ftext #text client_only_mod -justrc +if rc=1 filter #text -where client_only_mod -rep _false_true_ -write -yes +if rc=0 xed #text \"/[end]/\nclient_only_mod = true\n/\" -tofile #text"

::Ver 2.0.1
::sfk select . modinfo.lua +perline -yes "ftext #text client_only_mod -justrc +if rc=1 xed #text \"/*client_only_mod*/client_only_mod = true/\" -tofile #text +if rc=0 xed #text \"/[end]/\nclient_only_mod = true\n/\" -tofile #text"

::Ver 2.1.1
::sfk select . modinfo.lua +perline -yes "xed #text \"/[lstart]*client_only_mod*/client_only_mod = true/\" -tofile #text +if rc=0 xed #text \"/[end]/\nclient_only_mod = true\n/\" -tofile #text"

::Ver 2.1.1c
sfk select . modinfo.lua +perline -yes "xed #text \"/[lstart]*client_only_mod*/client_only_mod = true/\" -tofile #text +if rc=0 xed #text \"/[end]/\nclient_only_mod = true\n/\" -tofile #text +tell [Yellow]File: [Green]#file"
