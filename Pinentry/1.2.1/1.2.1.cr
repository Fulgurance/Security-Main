class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

    end

    def configure
        super

        configureSource(arguments:  "--prefix=/usr                                          \
                                    --enable-inside-emacs=#{option("Emacs") ? "yes" : "no"} \
                                    --enable-pinentry-qt=#{option("Qt") ? "yes" : "no"}     \
                                    --enable-pinentry-gtk2=#{option("Gtk+") ? "yes" : "no"} \
                                    --enable-pinentry-tty",
                        path:       buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource( arguments:  "DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath)
    end

end
