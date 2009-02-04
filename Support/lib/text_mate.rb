# Based on Ruby on Rails bundle

module TextMate
  class << self
    def env(var)
      ENV['TM_' + var.to_s.upcase]
    end

    # Forward to the TM_* environment variables if method is missing.  Some useful variables include:
    #   selected_text, current_line, column_number, line_number, support_path
    def method_missing(method, *args)
      if value = env(method)
        return value
      else
        super(method, *args)
      end
    end

    # TODO: Move cocoa dialog stuff to its own class or module

    def cocoa_dialog_command
      "#{support_path}/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog"
    end

    # See http://cocoadialog.sourceforge.net/documentation.html for documentation
    def cocoa_dialog(command, options = {})
      options_list = []
      options.each_pair do |k, v|
        k = k.to_s.gsub('_', '-')
        value = v.is_a?(Array) ? %Q{"#{v.join('" "')}"} : "\"#{v}\""
        if v
          if v.is_a? TrueClass
            options_list << "--#{k}"
          else
            options_list << "--#{k} #{value}"
          end
        end
      end
      dialog_command = "\"#{cocoa_dialog_command}\" #{command} #{options_list.join(' ')}"
      # $logger.debug "Dialog command: #{dialog_command}"
      `#{dialog_command}`.to_a.map { |v| v.strip }
    end

    # Shows an information bubble with a nice gradient background
    #
    def message(text, options = {})
      options = {:title => "Message", :informative_text => text, :button1 => "Ok"}.update(options)
      return cocoa_dialog('msgbox', options)[0] == "1"
    end

    def textbox(informative_text, text, options = {})
      options = {:title => "Message", :informative_text => informative_text, :text => text, :button1 => "Ok"}.update(options)
      return cocoa_dialog('textbox', options)[0] == "1"
    end

    def message_yes_no_cancel(text, options = {})
      options = {:title => "Message", :text => text}.update(options)
      return cocoa_dialog('yesno-msgbox', options)[0] == "1"
    end

    def message_ok_cancel(text, informative_text = nil, options = {})
      options = {:title => "Message", :text => text, :informative_text => informative_text}.update(options)
      return cocoa_dialog('ok-msgbox', options)[0] == "1"
    end

    def input(text, default_text = "", options = {})
      options = {:title => "Input", :informative_text => text, :text => default_text}.update(options)
      button, text = cocoa_dialog('standard-inputbox', options)
      if button == '1'
        return text.strip
      else
        return nil
      end
    end

    def choose(text, choices = ["none"], options = {})
      options = {:title => "Choose", :text => text, :items => choices, :button1 => 'Ok', :button2 => 'Cancel'}.update(options)
      button, choice = cocoa_dialog('dropdown', options)
      if button == '1'
        return choice.strip.to_i
      else
        return nil
      end
    end

  end
end
