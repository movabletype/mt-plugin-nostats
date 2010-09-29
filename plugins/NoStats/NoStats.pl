package MT::Plugin::NoStats;

use strict;
use warnings;

use base qw( MT::Plugin );
use MT;

use vars qw( $VERSION $PLUGIN_ID );
$VERSION = '0.32';
$PLUGIN_ID = 'no_stats';

my $plugin = MT::Plugin::NoStats->new ({
    id => $PLUGIN_ID,
    name        => 'NoStats',
    description => 'No stats!',
    version     => $VERSION,

    author_name => 'Six Apart',
    author_link => 'http://www.sixapart.com/',
});
MT->add_plugin ($plugin);

sub init_registry {
    my $component = shift;
    my $reg = {

        author      => 'Six Apart',
        init_app            => \&initialize,
        callbacks => {
            'MT::App::CMS::template_source.blog_stats'   => \&source_dashboard,
        },
    };
    $component->registry($reg);
}

sub initialize {
    my $plugin = shift;
    my ($app) = @_;
    eval { require MT::Community::CMS; };
    if (!$@) {
        my $mt_most_popular_entries_widget = \&MT::Community::CMS::most_popular_entries_widget;
        {
            local $SIG{__WARN__} = sub {  };
            *MT::Community::CMS::most_popular_entries_widget = \&most_popular_entries_widget;
        }
    }
    require MT::CMS::Dashboard;
    my $mt_generate_dashboard_stats = \&MT::CMS::Dashboard::generate_dashboard_stats;
    {
        local $SIG{__WARN__} = sub {  };
        *MT::CMS::Dashboard::generate_dashboard_stats = \&generate_dashboard_stats;
    }
}

sub generate_dashboard_stats {
    return 0;
}

sub most_popular_entries_widget {
    1;
}

sub source_dashboard {
    my ($cb, $app, $template) = @_;
    my $old = q{<mt:setvarblock name="error"><__trans phrase="Movable Type was unable to locate your 'mt-static' directory. Please configure the 'StaticFilePath' configuration setting in your mt-config.cgi file, and create a writable 'support' directory underneath your 'mt-static' directory."></mt:setvarblock>};
    $old = quotemeta($old);
    $$template =~ s/$old//;
    $old = q{<mtapp:statusmsg
            id="generic-error"
            class="error">
            <mt:var name="error">
        </mtapp:statusmsg>};
    $old = quotemeta($old);
    $$template =~ s/$old//;
}

1;
