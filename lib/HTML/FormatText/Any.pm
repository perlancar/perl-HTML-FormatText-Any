package HTML::FormatText::Any;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Exporter qw(import);
our @EXPORT_OK = qw(html2text);

our %SPEC;

$SPEC{html2text} = {
    v => 1.1,
    summary => 'Render HTML as text using one of multiple backends',
    description => <<'_',

Backends are tried in the following order (order is chosen based on rendering
quality):

* <pm:HTML::FormatText::Elinks> (using external program 'elinks')
* <pm:HTML::FormatText::Links> (using external program 'links')
* <pm:HTML::FormatText::W3m> (using external program 'w3m')
* <pm:HTML::FormatText::Lynx> (using external program 'lynx')
* <pm:HTML::FormatText::WithLinks::AndTables>

_
    args => {
        html => {
            schema => 'str*',
            req => 1,
            tags => ['category:input'],
            pos => 0,
            cmdline_src => 'stdin_or_files',
        },
        # XXX option to customize order of backends
    },
    links => [
        {url => 'prog:html2text', summary => 'CLI for this module'},
        {url => 'prog:html2txt', summary => 'a simpler HTML rendering utility which basically just strips HTML tags from HTML source code'},
    ],
    'cmdline.skip_format' => 1,
};
sub html2text {
    require File::Which;

    my %args = @_;
    my $html = $args{html} or return [400, "Please specify html"];

  ELINKS:
    {
        last unless File::Which::which("elinks");
        log_trace "Trying to render HTML using elinks ...";
        require HTML::FormatText::Elinks;
        my $text = HTML::FormatText::Elinks->format_string($html);
        unless (defined $text) {
            log_trace "Couldn't render using elinks, ".
                "trying another backend";
            last;
        }
        return [200, "OK (elinks)", $text];
    }

  LINKS:
    {
        last unless File::Which::which("links");
        log_trace "Trying to render HTML using links ...";
        require HTML::FormatText::Links;
        my $text = HTML::FormatText::Links->format_string($html);
        unless (defined $text) {
            log_trace "Couldn't render using links, ".
                "trying another backend";
            last;
        }
        return [200, "OK (links)", $text];
    }

  W3M:
    {
        last unless File::Which::which("w3m");
        log_trace "Trying to render HTML using w3m ...";
        require HTML::FormatText::W3m;
        my $text = HTML::FormatText::W3m->format_string($html);
        unless (defined $text) {
            log_trace "Couldn't render using w3m, ".
                "trying another backend";
            last;
        }
        return [200, "OK (w3m)", $text];
    }

  LYNX:
    {
        last unless File::Which::which("lynx");
        log_trace "Trying to render HTML using lynx ...";
        require HTML::FormatText::Lynx;
        my $text = HTML::FormatText::Lynx->format_string($html);
        unless (defined $text) {
            log_trace "Couldn't render using lynx, ".
                "trying another backend";
            last;
        }
        return [200, "OK (lynx)", $text];
    }

    # fallback
    log_trace "Rendering HTML using HTML::FormatText::WithLinks::AndTables ...";
    require HTML::FormatText::WithLinks::AndTables;
    my $text = HTML::FormatText::WithLinks::AndTables->convert($html);
    [200, "OK (HTML::FormatText::WithLinks::AndTables)", $text];
}

1;
# ABSTRACT:

=cut
