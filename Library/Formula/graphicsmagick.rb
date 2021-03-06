require 'formula'

def ghostscript_fonts?
  File.directory? "#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
end

def ghostscript_srsly?
  build.include? 'with-ghostscript'
end

def use_wmf?
  build.include? 'use-wmf'
end

def quantum_depth
  if build.include? 'with-quantum-depth-32'
    32
  elsif build.include? 'with-quantum-depth-16'
    16
  end
end

class Graphicsmagick < Formula
  homepage 'http://www.graphicsmagick.org/'
  url 'http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.15/GraphicsMagick-1.3.15.tar.bz2'
  sha256 'fd79168feaca5a2d230ce294541bb3655fd0fb6f21aec7c29dd7f00db14109ed'

  head 'hg://http://graphicsmagick.hg.sourceforge.net:8000/hgroot/graphicsmagick/graphicsmagick'

  depends_on :x11
  depends_on 'jpeg'
  depends_on 'libwmf' if use_wmf?
  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'jasper' => :optional
  depends_on 'ghostscript' => :recommended if ghostscript_srsly?
  depends_on 'xz' => :optional

  fails_with :llvm do
    build 2335
  end

  def skip_clean? path
    path.extname == '.la'
  end

  option 'with-ghostscript', 'Compile against ghostscript (not recommended.)'
  option 'without-magick-plus-plus', "Don't build C++ library."
  option 'use-wmf', 'Compile with libwmf support.'
  option 'with-quantum-depth-16', 'Use an 16 bit pixel quantum depth (default is 8)'
  option 'with-quantum-depth-32', 'Use a 32 bit pixel quantum depth (default is 8)'

  def install
    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'

    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--enable-shared", "--disable-static"]
    args << "--without-magick-plus-plus" if build.include? 'without-magick-plus-plus'
    args << "--disable-openmp" if MacOS.leopard? or ENV.compiler == :clang # libgomp unavailable
    args << "--with-gslib" if ghostscript_srsly?
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" \
              unless ghostscript_fonts?
    args << "--with-quantum-depth=#{quantum_depth}" if quantum_depth

    system "./configure", *args
    system "make install"
  end
end
