class Target < ISM::Software
    
    def configure
        super

        runFile(file:       "config",
                arguments:  "--prefix=/usr          \
                            --openssldir=/etc/ssl   \
                            --libdir=lib            \
                            shared                  \
                            zlib-dynamic",
                path:       buildDirectoryPath)
    end
    
    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        fileReplaceText(path:       "#{buildDirectoryPath}/Makefile",
                        text:       "INSTALL_LIBS=libcrypto.a libssl.a",
                        newText:    "INSTALL_LIBS=")

        makeSource( arguments:  "MANSUFFIX=ssl DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath)
    end

end
