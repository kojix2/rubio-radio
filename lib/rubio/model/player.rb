# frozen_string_literal: true

module Rubio
  module Model
    class Player
      attr_accessor :backend, :pid, :thr, :status, :history

      def initialize(backend = OS.linux? ? 'cvlc' : 'vlc -I rc')
        raise unless backend.is_a?(String)

        @backend = backend
        @pid = nil
        @thr = nil
        @status = []
        @history = []
      end

      def alive?
        return false if @thr.nil?

        @thr.alive?
      end

      def stop?
        @thr.nil? || @thr.stop?
      end

      def play(url)
        # Do not include spaces in the command line
        # if a space exist :
        #   * sh -c command url # this process with @pid will be killed
        #   * cmmand url        # will not be killd because pid is differennt
        # if no space :
        #   * cmmand url        # will be killed by @pid
        raise if url.match(/\s/)

        @pid = spawn(*backend.split(' '), url)
        @thr = Process.detach(@pid)
        @status = [@pid, @thr]
        @history << @status
      end

      def stop
        return unless alive?

        r = Process.kill(OS.windows? ? :KILL : :TERM, pid)
        @thr = nil
        @pid = nil
        r
      end

      def stop_all
        @history.each do |pid, thr|
          Process.kill(OS.windows? ? :KILL : :TERM, pid) if thr.alive?
        end
      end
    end
  end
end
