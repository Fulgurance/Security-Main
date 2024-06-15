class Target < ISM::Software

    def prepare
        if option("32Bits") || option("x32Bits")
            @buildDirectory = true
        end

        if option("32Bits")
            @buildDirectoryNames["32Bits"] = "mainBuild-32"
        end

        if option("x32Bits")
            @buildDirectoryNames["x32Bits"] = "mainBuild-x32"
        end
        super
    end
    
    def configure
        super

        runFile(file:       "config",
                arguments:  "--prefix=/usr          \
                            --openssldir=/etc/ssl   \
                            --libdir=lib            \
                            shared                  \
                            zlib-dynamic",
                path:       buildDirectoryPath(entry: "MainBuild"))

        if option("32Bits")
            runFile(file:   "config",
                    arguments:  "--prefix=/usr          \
                                --openssldir=/etc/ssl   \
                                --libdir=lib32          \
                                shared                  \
                                zlib-dynamic            \
                                linux-x86",
                    path:       buildDirectoryPath(entry: "MainBuild"))
        end

        if option("x32Bits")
            runFile(file:       "config",
                    arguments:  "--prefix=/usr          \
                                --openssldir=/etc/ssl   \
                                --libdir=libx32         \
                                shared                  \
                                zlib-dynamic            \
                                linux-x32",
                    path:       buildDirectoryPath(entry: "MainBuild"))
        end
    end
    
    def build
        super

        makeSource(path: buildDirectoryPath(entry: "MainBuild"))

        if option("32Bits")
            makeSource(path: buildDirectoryPath(entry: "32Bits"))
        end

        if option("x32Bits")
            makeSource(path: buildDirectoryPath(entry: "x32Bits"))
        end
    end
    
    def prepareInstallation
        super

        fileReplaceText(path:       "#{buildDirectoryPath}/Makefile",
                        text:       "INSTALL_LIBS=libcrypto.a libssl.a",
                        newText:    "INSTALL_LIBS=")

        makeSource( arguments:  "MANSUFFIX=ssl DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath(entry: "MainBuild"))

        moveFile(   "#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}/usr/share/doc/openssl",
                    "#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}/usr/share/doc/openssl-3.1.2")

        if option("32Bits")
            makeDirectory("#{buildDirectoryPath(entry: "32Bits")}/32Bits")
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr")

            makeSource( arguments:  "DESTDIR=#{buildDirectoryPath(entry: "32Bits")}/32Bits install",
                        path:       buildDirectoryPath(entry: "32Bits"))

            copyDirectory(  "#{buildDirectoryPath(entry: "32Bits")}/32Bits/usr/lib32",
                            "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib32")
        end

        if option("x32Bits")
            makeDirectory("#{buildDirectoryPath(entry: "x32Bits")}/x32Bits")
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr")

            makeSource( arguments:  "DESTDIR=#{buildDirectoryPath(entry: "x32Bits")}/x32Bits install",
                        path:       buildDirectoryPath(entry: "x32Bits"))

            copyDirectory(  "#{buildDirectoryPath(entry: "x32Bits")}/x32Bits/usr/libx32",
                            "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/libx32")
        end
    end

end
