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

        runScript(  "config",
                    ["--prefix=/usr",
                    "--openssldir=/etc/ssl",
                    "--libdir=lib",
                    "shared",
                    "zlib-dynamic"],
                    path: buildDirectoryPath(entry: "mainBuild"))

        if option("32Bits")
            runScript(  "config",
                        ["--prefix=/usr",
                        "--openssldir=/etc/ssl",
                        "--libdir=lib32",
                        "shared",
                        "zlib-dynamic",
                        "linux-x86"],
                        path: buildDirectoryPath(entry: "mainBuild"))
        end

        if option("x32Bits")
            runScript(  "config",
                        ["--prefix=/usr",
                        "--openssldir=/etc/ssl",
                        "--libdir=libx32",
                        "shared",
                        "zlib-dynamic",
                        "linux-x32"],
                        path: buildDirectoryPath(entry: "mainBuild"))
        end
    end
    
    def build
        super

        makeSource(path: buildDirectoryPath(entry: "mainBuild"))

        if option("32Bits")
            makeSource(path: buildDirectoryPath(entry: "32Bits"))
        end

        if option("x32Bits")
            makeSource(path: buildDirectoryPath(entry: "x32Bits"))
        end
    end
    
    def prepareInstallation
        super

        fileReplaceText("#{buildDirectoryPath(false)}/Makefile",
                        "INSTALL_LIBS=libcrypto.a libssl.a",
                        "INSTALL_LIBS=")

        makeSource( ["MANSUFFIX=ssl","DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}",
                    "install"],
                    path: buildDirectoryPath(entry: "mainBuild"))

        moveFile(   "#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/share/doc/openssl",
                    "#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/share/doc/openssl-3.1.2")

        if option("32Bits")
            makeDirectory("#{buildDirectoryPath(false, entry: "32Bits")}/32Bits")
            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/usr")

            makeSource( ["DESTDIR=#{buildDirectoryPath(entry: "32Bits")}/32Bits",
                        "install"],
                        path: buildDirectoryPath(entry: "32Bits"))

            copyDirectory(  "#{buildDirectoryPath(false, entry: "32Bits")}/32Bits/usr/lib32",
                            "#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/usr/lib32")
        end

        if option("x32Bits")
            makeDirectory("#{buildDirectoryPath(false, entry: "x32Bits")}/x32Bits")
            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/usr")

            makeSource( ["DESTDIR=#{buildDirectoryPath(entry: "x32Bits")}/x32Bits",
                        "install"],
                        path: buildDirectoryPath(entry: "x32Bits"))

            copyDirectory(  "#{buildDirectoryPath(false, entry: "x32Bits")}/x32Bits/usr/libx32",
                            "#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/usr/libx32")
        end
    end

end
