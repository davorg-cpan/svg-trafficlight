package SVG::TrafficLight;

use strict;
use warnings;

use Moose;
use SVG;

has radius => (
  is      => 'ro',
  isa     => 'Num',
  default => 50,
);

sub diameter {
  my $self = shift;

  return $self->radius * 2;
}

has padding => (
  is         => 'ro',
  isa        => 'Num',
  lazy_build => 1,
);

sub _build_padding {
  return shift->radius * .5;
}

has light_width => (
  is         => 'ro',
  isa        => 'Num',
  lazy_build => 1,
);

sub _build_light_width {
  my $self = shift;

  # A light is a diameter plus two paddings
  return $self->diameter + (2 * $self->padding);
}

has light_height => (
  is         => 'ro',
  isa        => 'Num',
  lazy_build => 1,
);

sub _build_light_height {
  my $self = shift;

  # Height is three diameters + four paddings
  return (3 * $self->diameter) + (4 * $self->padding);
}

has width => (
  is         => 'ro',
  isa        => 'Num',
  lazy_build => 1,
);

sub _build_width {
  my $self = shift;

  my $count_lights = scalar @{ $self->sequence };

  # One light is 2 * radius
  # + 2 * padding
  my $one_light = $self->light_width;

  # Multiply by the number of lights
  my $lights = $count_lights * $one_light;

  # Add padding at the edges and between the lights
  return ($count_lights + 1) * $self->padding + $lights;
}

has height => (
  is         => 'ro',
  isa        => 'Num',
  lazy_build => 1,
);

sub _build_height {
  my $self = shift;

  # Height of a light bank + two lots of padding
  return $self->light_height + (2 * $self->padding);
}

has corner_radius => (
  is      => 'ro',
  isa     => 'Num',
  default => 20,
);

has svg => (
  is         => 'ro',
  isa        => 'SVG',
  lazy_build => 1,
  handles    => [ qw(rect circle xmlify) ],
);

sub _build_svg {
  my $self = shift;

  return SVG->new(
    width  => $self->width,
    height => $self->height,
  );
}

has colours => (
  is      => 'ro',
  isa     => 'HashRef',
  default => sub { {
    red   => ['rgb(63,0,0)',  'red'],
    amber => ['rgb(59,29,0)', 'orange'],
    green => ['rgb(0,63,0)',  'green'],
  } },
);

has sequence => (
  is => 'ro',
  isa => 'ArrayRef',
  default => sub { [{
    red   => 0,
    amber => 0,
    green => 1,
  }, {
    red   => 0,
    amber => 1,
    green => 0,
  }, {
    red   => 1,
    amber => 0,
    green => 0,
  }, {
    red   => 1,
    amber => 1,
    green => 0,
  }, {
    red   => 0,
    amber => 0,
    green => 1,
  }] },
);

sub BUILD {
  my $self = shift;

  for my $i (0 .. $#{$self->sequence}) {
    my $light_set_x = ($i * ($self->light_width + $self->padding))
                      + $self->padding;

    $self->rect(
      x      => $light_set_x,
      y      => $self->padding,
      width  => $self->light_width,
      height => $self->light_height,
      fill   => 'black',
      rx     => $self->corner_radius,
      ry     => $self->corner_radius,
    );

    my $light = 0;
    for my $l (qw[red amber green]) {
      my $fill = $self->colours->{$l}[$self->sequence->[$i]{$l}];

      $self->circle(
        cx   => $light_set_x + $self->padding + $self->radius,
        cy   => (2 * $self->padding) + $self->radius
                + $light * ($self->diameter + $self->padding),
        r    => $self->radius,
        fill => $fill,
      );
      ++$light;
    }
  }
}

1;
