# This closely mirrors the default homebrew Mutt formula. It adds additional
# patches to improve functionality because the Homebrew project will not accept
# any more patches to the standard formula.
#
# This formula adds the following build flags:
# --with-sidebar-patch which adds and 'outlook' or 'mail.app' style sidebar
# --with-index-color-patch adds syntax-highlighting to the message index
# --with-trash-patch which adds a "trash" folder where deleted messages are
# sent automatically instead of being left to clutter mailboxes.
#
# Note that the index-color-patch and sidebar-patch conflict with one-another
# and you must choose one or the other to install.
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

  conflicts_with "tin",
    :because => "both install mmdf.5 and mbox.5 man pages"

  option "with-debug", "Build with debug option enabled"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-index-color-patch", "Apply index color patch"
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

  if build.with? "confirm-attachment-patch"
    patch do
      url "https://gist.githubusercontent.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch"
      sha256 "da2c9e54a5426019b84837faef18cc51e174108f07dc7ec15968ca732880cb14"
    end
  end

  if build.with? "trash-patch"
    patch do
      url "https://blog.x-way.org/stuff/mutt-1.5.24-trash_folder.diff"
      sha256 "985d7f6ae17e15e525b19e348b3a43e78177cea3b775434abcbe7d220bebe934"
    end
  end

  if build.with? "index-color-patch"
    patch do
      url "https://blog.x-way.org/stuff/mutt-1.5.24-indexcolor.diff"
      sha256 "96c3ab28e0cb03646fbb0357650628591efabb102596978d1b05960d0e511f33"
    end
  end

  if build.with? "sidebar-patch"
    patch do
      url "http://lunar-linux.org/~tchan/mutt/patch-1.5.24.sidebar.20150917.txt"
      sha256 "ddc2baeb4d882ac32b5c54965dfb3a9b3164b2387888be33f4c1d16ebbea5b98"
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
