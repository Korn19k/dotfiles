# Powerline prompt theme
# Ported to Elvish by Christian Muehlhaeuser <muesli@gmail.com>
# Based on chain.elv by Diego Zamboni <diego@zzamboni.org>
#
# To use, put this file in ~/.elvish/lib/theme and add the following to your ~/.elvish/rc.elv file:
#   use theme:powerline
#   theme:powerline:setup
#
# You can also assign the prompt functions manually instead of calling `powerline:setup`:
#   edit:prompt = $powerline:&prompt
#   edit:rprompt = $powerline:&rprompt
#
# The chains on both sides can be configured by assigning to `theme:powerline:prompt_segments` and
# `theme:powerline:rprompt_segments`, respectively. These variables must be arrays, and the given
# segments will be automatically linked by `$theme:powerline:glyph[chain]`. Each element can be any
# of the following:
#
# - The name of one of the built-in segments. Available segments:
#     `newline` `user` `host` `arrow` `timestamp` `su` `dir` `git_branch` `git_dirty`
# - A string or the output of `edit:styled`, which will be displayed as-is.
# - A lambda, which will be called and its output displayed
# - The output of a call to `theme:powerline:segment <style> <strings>`, which returns a "proper"
#   segment, enclosed in square brackets and styled as requested.
#

# Default values (all can be configured by assigning to the appropriate variable):

# Configurable prompt segments for each prompt
prompt_segments = [ host dir git_branch git_dirty newline su user timestamp arrow ]
rprompt_segments = [ ]

# Glyphs to be used in the prompt
glyph = [
	&prefix= " "
	&suffix= " "
	&arrow= ""
	&git_branch= "⎇"
	&git_dirty= "±"
	&su= "⚡"
  &cache= "∼"
	&chain= ""
	&dirchain= "  "
]

# Styling for each built-in segment. The value must be a valid argument to `edit:styled`
segment_style_fg = [
	&arrow= "0"
	&su= "250"
	&cache= "15"
	&dir= "15"
	&user= "250"
	&host= "254"
	&git_branch= "0"
	&git_dirty= "15"
	&timestamp= "250"
]

segment_style_bg = [
	&arrow= "0"
	&su= "124"
	&cache= "31"
	&dir= "31"
	&user= "240"
	&host= "166"
	&git_branch= "148"
	&git_dirty= "161"
	&timestamp= "238"
]

# To how many letters to abbreviate directories in the path - 0 to show in full
prompt_pwd_dir_length = 0

# Format to use for the 'timestamp' segment, in strftime(3) format
timestamp_format = "%H:%M:%S"

# User ID that will trigger the "su" segment. Defaults to root.
root_id = 0

# If $true, the chain is only generated after each command and not on every keystroke
# This improves typing speed sometimes (e.g. in large git repos when you have the
# git segments enabled) but may cause prompt refresh problems sometimes until
# you press Enter after a directory change or some other change.
cache_chain = $false

# Threshold in milliseconds for auto-enabling prompt caching
auto_cache_threshold_ms = 100

# Cached generated prompt - since arbitrary commands can be executed, we compute
# the prompt only before displaying it and not on every keystroke, and we cache
# the prompts here.
cached_prompt = [ ]
cached_rprompt = [ ]

last_bg = ""

######################################################################

# Convert output from -time function to a number in ms
fn -time-to-ms [n]{
  pat = (re:find '^([\d.]+)(.*)$' $n)
  num unit = $pat[groups][1 2][text]
  factor = [&s=1000 &ms=1 &µs=.001]
  * $num $factor[$unit]
}

fn -log [@msg]{
  echo (date) $@msg >> /tmp/chain-debug.log
}

fn -colorprint [what fg bg]{
  edit:styled $what "38;5;"$fg";48;5;"$bg
  last_bg = $bg
}

# Build a prompt segment in the given style, surrounded by square brackets
fn prompt_segment [fg bg @texts]{
	text = $glyph[prefix](joins ' ' $texts)$glyph[suffix]
	-colorprint $text $fg $bg
}

# Return the git branch name of the current directory
fn -git_branch_name {
  out = ""
  err = ?(out = (git branch 2>/dev/null | eawk [line @f]{
        if (eq $f[0] "*") {
          if (and (> (count $f) 2) (eq $f[2] "detached")) {
            replaces ')' '' $f[4]
          } else {
            echo $f[1]
          }
        }
  }))
  put $out
}

# Return whether the current git repo is "dirty" (modified in any way)
fn -git_is_dirty {
  out = []
  err = ?(out = [(git status -s --ignore-submodules=dirty 2>/dev/null)])
  > (count $out) 0
}

# Return the current directory, shortened according to `$prompt_pwd_dir_length`
fn -prompt_pwd {
	tmp = (tilde-abbr $pwd)
	if (== $prompt_pwd_dir_length 0) {
		put $tmp
	} else {
		re:replace '(\.?[^/]{'$prompt_pwd_dir_length'})[^/]*/' '$1/' $tmp
	}
}

######################################################################
# Built-in chain segments

fn segment_newline {
  put "\n"
}

fn segment_su {
	uid = (id -u)
	if (eq $uid $root_id) {
		prompt_segment $segment_style_fg[su] $segment_style_bg[su] $glyph[su]
	}
}

fn segment_cache {
  if $cache_chain {
    prompt_segment $segment_style_fg[cache] $segment_style_bg[cache] $glyph[cache]
  }
}

fn segment_dir {
  prompt_segment $segment_style_fg[dir] $segment_style_bg[dir] (-prompt_pwd)
}

fn segment_user {
	prompt_segment $segment_style_fg[user] $segment_style_bg[user] (whoami)
}

fn segment_host {
	prompt_segment $segment_style_fg[host] $segment_style_bg[host] (hostname)
}

fn segment_git_branch {
  branch = (-git_branch_name)
  if (not-eq $branch "") {
	  prompt_segment $segment_style_fg[git_branch] $segment_style_bg[git_branch] $glyph[git_branch] $branch$glyph[suffix]
  }
}

fn segment_git_dirty {
	if (-git_is_dirty) {
	  prompt_segment $segment_style_fg[git_dirty] $segment_style_bg[git_dirty] $glyph[git_dirty]
	}
}

fn segment_arrow {
	edit:styled $glyph[arrow]" " $segment_style_fg[arrow]
}

fn segment_timestamp {
	prompt_segment $segment_style_fg[timestamp] $segment_style_bg[timestamp] (date +$timestamp_format)
}

# List of built-in segments
segment = [
	&newline= $&segment_newline
	&su= $&segment_su
	&cache= $&segment_cache
	&dir= $&segment_dir
	&user= $&segment_user
	&host= $&segment_host
	&git_branch= $&segment_git_branch
	&git_dirty= $&segment_git_dirty
	&arrow= $&segment_arrow
	&timestamp= $&segment_timestamp
]

# Given a segment specification, return the appropriate value, depending
# on whether it's the name of a built-in segment, a lambda, a string
# or an edit:styled
fn -interpret-segment [seg]{
	k = (kind-of $seg)
	if (eq $k fn) {
		# If it's a lambda, run it
		$seg
	} elif (eq $k string) {
		if (has-key $segment $seg) {
			# If it's the name of a built-in segment, run its function
			$segment[$seg]
		} else {
			# If it's any other string, return it as-is
			put $seg
		}
	} elif (eq $k styled) {
		# If it's an edit:styled, return it as-is
		put $seg
	}
}

# Return a string of values, including the appropriate chain connectors
fn -build-chain [segments]{
	first = $true
  output = ""
	for seg $segments {
    lbg = $last_bg
		time = (-time { output = [(-interpret-segment $seg)] })
    #    -log $pwd segment-$seg $time
	  if (> (count $output) 0) {
		  if (not $first) {
        if (not (eq $seg "newline")) {
          -colorprint $glyph[chain] $lbg $segment_style_bg[$seg]
        } else {
          -colorprint $glyph[chain] $lbg "0"
        }
		  }
		  put $@output
      if (not (eq $seg "newline")) {
        first = $false
      } else {
        first = $true
      }
	  }
	}
}

# Check if the time exceeds the threshold for enabling/disabling
# caching We have separate functions for enabling/disabling because
# they are called from different points - the "enabling" functions are
# called after each chain generation (so that either prompt or rprompt
# taking too long can trigger the caching), while the "disabling"
# functions are called only from the "cache_prompts" function, so that
# caching is disabled only when both prompts are fast.
fn -check_time_for_enabling_caching [t]{
  ms = (-time-to-ms $t)
  if (>= $ms $auto_cache_threshold_ms) {
    if (not $cache_chain) {
      -log Chain build took $ms - enabling prompt caching
      theme:chain:cache $true
      edit:redraw
    }
  }
}

fn -check_time_for_disabling_caching [t]{
  ms = (-time-to-ms $t)
  if (< $ms $auto_cache_threshold_ms) {
    if $cache_chain {
      -log Chain build took $ms - disabling prompt caching
      theme:chain:cache $false
      edit:redraw
    }
  }
}

# Prompt and rprompt functions

fn prompt [@skipcheck]{
  out = []
  time = (-time { out = [(-build-chain $prompt_segments)] })
  if (== (count $skipcheck) 0) {
    -check_time_for_enabling_caching $time
  }
  put $@out
}

fn rprompt [@skipcheck]{
  out = []
  time = (-time { out = [(-build-chain $rprompt_segments)] } )
  if (== (count $skipcheck) 0) {
    -check_time_for_enabling_caching $time
  }
  put $@out
}

fn cache_prompts [@skipcheck]{
  time = (-time {
      cached_prompt = [(prompt $@skipcheck)]
      cached_rprompt = [(rprompt $@skipcheck)]
  })
  if (== (count $skipcheck) 0) {
    -check_time_for_disabling_caching $time
  }
  #  -log $pwd cache_prompts $time
}

# Default setup, assigning our functions to `edit:prompt` and `edit:rprompt`
fn setup {
  if $cache_chain {
    edit:before-readline=[ $@edit:before-readline $&cache_prompts ]
    edit:prompt = { put $@cached_prompt }
    edit:rprompt = { put $@cached_rprompt }
    cache_prompts skip_timecheck
  } else {
    edit:prompt = $&prompt
    edit:rprompt = $&rprompt
  }
}

# Toggle (or set, according to parameter) prompt caching
fn cache [@val]{
  value = (not $cache_chain)
  if (> (count $val) 0) {
    value = $val[0]
  }
  cache_chain = $value
  setup
}
