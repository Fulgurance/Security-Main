class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

    end

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--enable-inside-emacs=#{option("Emacs") ? "yes" : "no"}",
                            "--enable-pinentry-qt=#{option("Qt") ? "yes" : "no"}",
                            "--enable-pinentry-gtk2=#{option("Gtk+") ? "yes" : "no"}",
                            "--enable-pinentry-tty"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

end
