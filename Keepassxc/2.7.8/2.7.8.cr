class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super
    end

    def configure
        super

        runCmakeCommand([   "-DCMAKE_INSTALL_PREFIX=/usr",
                            "-DCMAKE_BUILD_TYPE=Release",
                            "-DWITH_XC_DOCS=OFF",
                            "-DWITH_GUI_TESTS=OFF",
                            "-DWITH_TESTS=OFF",
                            ".."],
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