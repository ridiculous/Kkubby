module FlashHelper
  SUCCESS_MESSAGES = ["Excellent", "Success", "Nice job", "Sweet", "Very nice"].freeze
  FAIL_MESSAGES = ["Hold up", "Oops", "Uh-uh", "Whoops", "Nope"].freeze

  def flash_messages
    @flash_messages ||= request.flash.discard.collect { |_, msg| msg }
  end

  def flash_message_helper
    flash_box(flash_type, flash_prefix) if request.flash.any?
  end

  def flash_prefix
    if flash_messages.first.is_a?(Array)
      flash_messages.first.shift
    elsif flash_type == 'notice'
      "#{SUCCESS_MESSAGES.sample}."
    else
      "#{FAIL_MESSAGES.sample}."
    end
  end

  def flash_type
    @flash_type ||= request.flash.to_hash.keep_if { |_, val| val.present? }.keys.first
  end

  def flash_box(the_type, the_prefix)
    content_tag(:div, class: "box-type-#{the_type} medium-major") do
      # concat('<button type="button" class="fr" id="close-alert">&times;</button>'.html_safe)
      concat(flash_messages.push("<b>#{the_prefix}</b>").reverse.join(' ').html_safe)
    end
  end
end
