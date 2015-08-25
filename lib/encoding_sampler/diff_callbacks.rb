require "cgi"
require 'encoding_sampler/diff_hunk'

module EncodingSampler
  
  # Simple formatter to override Diff::LCS::DiffCallbacks in diff-lcs Gem to generate diffed output.
  class DiffCallbacks
    attr_reader :difference_start
    # @!attribute [r] difference_start
    #   @return [String] The string inserted in the diff results __before__ a segment where the samples differ.
    #     Set as option on initialization.

    attr_reader :difference_end
    # @!attribute [r] difference_end
    #   @return [String] The string inserted in the diff results __after__ a segment where the samples differ.
    #     Set as option on initialization.

    # @return [DiffCallbacks] Returns a new instance of EncodingSampler::DiffCallbacks.
    # @param [Hash] options
    #   Valid keys are :difference_start and :difference_end.
    # @see #difference_start
    # @see #difference_end
    def initialize(options = {})
      @diff_hunks = []
      options ||= {}
      @difference_start = options[:difference_start] ||= '<span class="difference">'
      @difference_end = options[:difference_end] ||= '</span>'
      @match_start = options[:match_start] ||= ''
      @match_end = options[:match_end] ||= ''
    end

    def clear_buffer
      @diff_hunks.clear
    end

    def line_number=(val)
      @line_number = val
    end

    # Called with both strings are the same
    def match(event)
      output_matched event.old_element
    end
  
    # Called when there is a substring in A that isn't in B
    def discard_a(event)
      output_changed event.old_element
    end
  
    # Called when there is a substring in B that isn't in A
    def discard_b(event)
      output_changed event.new_element
    end

    def result
      @diff_hunks.map { |h| h.result }.join ''
    end
    
  private
   
    def output_matched(element)
      element = CGI.escapeHTML(element.chomp)
      return if element.empty?
      unless (hunk = @diff_hunks.last) && hunk.type == :match
        hunk = DiffHunk.new :match, @match_start, @match_end
        @diff_hunks << hunk
      end
      hunk << element
    end
  
    def output_changed(element)
      element = CGI.escapeHTML(element.chomp)
      return if element.empty?
      unless (hunk = @diff_hunks.last) && hunk.type == :difference
        hunk = DiffHunk.new :difference, @difference_start, @difference_end
        @diff_hunks << hunk
      end
      hunk << element
    end
     
  end
end
