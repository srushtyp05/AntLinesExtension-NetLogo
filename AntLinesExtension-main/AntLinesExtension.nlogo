breed [leaders leader]
breed [followers follower]

globals [
  nest-x nest-y    ;; location of the center of the nest
  food-x food-y    ;; location of the center of food
  num-obstacles    ;; number of obstacles
]

patches-own [obstacle?]

to setup
  clear-all
  set-default-shape turtles "bug"
  set nest-x 10 + min-pxcor
  set nest-y 0
  set food-x max-pxcor - 10
  set food-y 0
  set num-obstacles 15  ;; Set the number of obstacles

  ;; Initialize all patches as non-obstacles
  ask patches [ set obstacle? false ]

  ;; Create obstacles at random patches
  repeat num-obstacles [
    let obstacle-patch one-of patches with [not obstacle?]
    ifelse is-patch? obstacle-patch [
      ask obstacle-patch [
        set obstacle? true
        set pcolor gray  ;; You can set the color of obstacle patches as gray
      ]
    ] [
      print "No more patches available for obstacles."
      stop
    ]
  ]

    ;; draw the nest in brown by stamping a circular
  ;; brown turtle
  ask patch nest-x nest-y [
    sprout 1 [
      set color brown
      set shape "square"
      set size 15
      stamp
      die
    ]
  ]



  ;; Draw the food in orange by stamping a circular orange turtle
  ask patch food-x food-y [
    sprout 1 [
      set color red
      set shape "square"
      set size 15
      stamp
      die
    ]
  ]

  create-leaders 1 [set color red]  ;; Leader ant is red and starts with a random heading

  create-followers (num-ants - 1) [
    set color yellow  ;; Middle ants are yellow
    set heading 90   ;; Start with a fixed heading
  ]

  ask turtles [
    setxy nest-x nest-y
    set size 2
  ]

  ask turtle (max [who] of turtles) [
    set color blue  ;; Last ant is blue
    set pen-size 2
    pen-down  ;; Leaves a trail
  ]

  ask leaders [
    set pen-size 2
    pen-down  ;; The leader also leaves a trail
  ]

  reset-ticks
end

to go
  if all? turtles [xcor >= food-x]
  [ stop ]
  ask leaders
  [ wiggle leader-wiggle-angle
    correct-path
    if (xcor > (food-x - 5 ))
    [ facexy food-x food-y ]
    if xcor < food-x
    [ fd 0.5 ]
  ]

   ask followers
     [ face turtle (who - 1)                        ;; follower ants follow the ant ahead of them
       if time-to-start? and (xcor < food-x)        ;; followers wait a bit before leaving nest
         [ fd 0.5 ] ]
  tick
end


;; Turtle procedure; wiggle a random amount, averaging zero turn
to wiggle [angle]
  rt random-float angle
  lt random-float angle
end

;; Turtle procedure
to correct-path
  ifelse heading > 180
  [ rt 180 ]
  [ if patch-at 0 -5 = nobody
    [ rt 100 ]
    if patch-at 0 5 = nobody
    [ lt 100 ]
  ]
end
;; Turtle reporter; if true, then the ant is authorized to move out of the nest
to-report time-to-start?
  report ([xcor] of (turtle (who - 1))) > (nest-x + start-delay + random start-delay)
end