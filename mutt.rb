# This closely mirrors the default homebrew Mutt formula. It adds additional
# patches to improve functionality because the Homebrew project will not accept
# any more patches to the standard formula.
#
# This formula adds the following build flags:
# --with-sidebar-patch which adds and 'outlook' or 'mail.app' style sidebar
# --with-trash-patch which adds a "trash" folder where deleted messages are
# sent automatically instead of being left to clutter mailboxes.

class Mutt < Formula
  desc "The Mutt mail client with sidebar and trash patches"
  homepage "http://www.mutt.org/"
  url "https://bitbucket.org/mutt/mutt/downloads/mutt-1.5.24.tar.gz"
  mirror "ftp://ftp.mutt.org/pub/mutt/mutt-1.5.24.tar.gz"
  sha256 "a292ca765ed7b19db4ac495938a3ef808a16193b7d623d65562bb8feb2b42200"

  bottle do
    revision 2
    sha256 "5bb0c9590b522bbcc38bfecaf0561810db2660792f472aa12a3b6c8f5e5b28d7" => :el_capitan
    sha256 "8cad91b87b615984871b6bed35a029edcef006666bc7cf3b8f6b8b74d91c5b97" => :yosemite
    sha256 "c57d868588eb947002902c90ee68af78298cbb09987e0150c1eea73f9e574cce" => :mavericks
  end

  head do
    url "http://dev.mutt.org/hg/mutt#default", :using => :hg

    resource "html" do
      url "http://dev.mutt.org/doc/manual.html", :using => :nounzip
    end
  end

  unless Tab.for_name("signing-party").with? "rename-pgpring"
    conflicts_with "signing-party",
      :because => "mutt installs a private copy of pgpring"
  end

  conflicts_with "tin",
    :because => "both install mmdf.5 and mbox.5 man pages"

  option "with-debug", "Build with debug option enabled"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-indexicolor-patch", "Apply index color patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"
  option "with-sidebar-patch", "Apply sidebar patch"
  option "with-trash-patch", "Apply trash patch"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "openssl"
  depends_on "tokyo-cabinet"
  depends_on "gettext" => :optional
  depends_on "gpgme" => :optional
  depends_on "libidn" => :optional
  depends_on "s-lang" => :optional

  # original source for this went missing, patch sourced from Arch at
  # https://aur.archlinux.org/packages/mutt-ignore-thread/
  if build.with? "ignore-thread-patch"
    patch do
      url "https://gist.githubusercontent.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch"
      sha256 "7290e2a5ac12cbf89d615efa38c1ada3b454cb642ecaf520c26e47e7a1c926be"
    end
  end

  if build.with? "with-index-color-patch"
    patch do
      url "https://github.com/colinstein/homebrew-mutt/blob/master/indexcolor.patch"
      sha256 "44811aa166b3cb89c765c1019062cf0af76f3958596d0aa27b4fcfb7602a6bf6"
    end
  end

  if build.with? "confirm-attachment-patch"
    patch do
      url "https://gist.githubusercontent.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch"
      sha256 "da2c9e54a5426019b84837faef18cc51e174108f07dc7ec15968ca732880cb14"
    end
  end

  if build.with? "with-sidebar-patch"
    patch do
      url "https://raw.githubusercontent.com/colinstein/homebrew-mutt/master/sidebar.patch"
      sha256 "f4cf62c93d9a6a3fef9b00b8badc6dcec063f5c0d4b7484360dc21e94c3a1eac"
    end
  end

  if build.with? "with-trash-patch"
    patch do
      url "https://raw.githubusercontent.com/colinstein/homebrew-mutt/master/trash.patch"
      sha256 "970090f05bce7b914694099b6b93b2054f176a8da2b498e450a6e530e054d147"
    end
  end

  def install
    user_admin = Etc.getgrnam("admin").mem.include?(ENV["USER"])

    args = %W[
      --disable-dependency-tracking
      --disable-warnings
      --prefix=#{prefix}
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --with-sasl
      --with-gss
      --enable-imap
      --enable-smtp
      --enable-pop
      --enable-hcache
      --with-tokyocabinet
    ]

    # This is just a trick to keep 'make install' from trying
    # to chgrp the mutt_dotlock file (which we can't do if
    # we're running as an unprivileged user)
    args << "--with-homespool=.mbox" unless user_admin

    args << "--disable-nls" if build.without? "gettext"
    args << "--enable-gpgme" if build.with? "gpgme"
    args << "--with-slang" if build.with? "s-lang"

    if build.with? "debug"
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./prepare", *args
    system "make"

    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    if user_admin
      inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = admin"
    end

    system "make", "install"
    doc.install resource("html") if build.head?
  end

  test do
    system bin/"mutt", "-D"
  end
end
