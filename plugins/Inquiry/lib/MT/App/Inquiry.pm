package MT::App::Inquiry;
use strict;
use base qw( MT::App );
use MT::Mail;

sub _submit {
    my $app = shift;
    if ( $app->request_method ne 'POST' ) {
        return $app->trans_error( 'Invalid request.' );
    }
    my $param;
    my @inquiry_loop;
    for my $key ( $app->param ) {
        $param->{ $key } = $app->param( $key );
        push @inquiry_loop, { key => $key, 
                              value => $app->param( $key ) };
    }
    $param->{ inquiry_loop } = \@inquiry_loop;
    my $plugin = MT->component( 'Inquiry' );
    my $tmpl_body = File::Spec->catfile( $plugin->path, 'tmpl', 'mail_body.tmpl' );
    my $tmpl_subject = File::Spec->catfile( $plugin->path, 'tmpl', 'mail_subject.tmpl' );
    my $body = $app->build_page( $tmpl_body, $param );
    my $subject = $app->build_page( $tmpl_subject, $param );
    my $to = MT->config( 'InquirySendTo' );
    my %head = ( To => $to, Subject => $subject );
    MT::Mail->send( \%head, $body ) or die MT::Mail->errstr;
    # MT->log( "${subject}\n\n${body}" );
    my $url = MT->config( 'InquiryRedirectPath' );
    $app->redirect( $url );
}

1;