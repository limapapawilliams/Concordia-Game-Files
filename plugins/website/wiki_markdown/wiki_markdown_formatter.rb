module AresMUSH
  
  module Website
    
    # Enables the //italics// format that everyone is used to.
    class HTMLWithWikiExtensions < Redcarpet::Render::HTML
      def initialize(pre_tag_blocks, post_tag_blocks, sinatra, options)
        @pre_tag_blocks = pre_tag_blocks
        @post_tag_blocks = post_tag_blocks
        @sinatra = sinatra
        super options
      end
      
      def preprocess(text)
        return text if text =~ /\[\[disableWikiExtensions\]\]/
              
        @pre_tag_blocks.each do |tag|
          begin
            text = text.gsub(tag.regex) { tag.parse(Regexp.last_match) }
          rescue Exception => e
            Global.logger.warn "Error in wiki extension.  error=#{e} backtrace=#{e.backtrace[0,10]}"
          end
        end
        
        text
      end
      
      def autolink(link, link_type)
        "<a target=\"_blank\" href=\"#{link}\">#{link}</a>"
      end
      
      def postprocess(text)
        return text if text =~ /\[\[disableWikiExtensions\]\]/
        
        text = text.gsub(/\&quot\;/i, '"')
        
        @post_tag_blocks.each do |tag|
          begin
            text = text.gsub(tag.regex) { tag.parse(Regexp.last_match) }
          rescue Exception => e
            Global.logger.warn "Error in wiki extension.  error=#{e} backtrace=#{e.backtrace[0,10]}"
          end
        end
        
        text
      end
    end

    class WikiMarkdownFormatter
      def initialize(escape_html, sinatra)
        
        options = {
          tables: true,
          no_intra_emphasis: true,
          autolink: true,
          fenced_code_blocks: true,
          strikethrough: true
        }
            
        renderer = HTMLWithWikiExtensions.new(
        WikiMarkdownExtensions.preprocess_tags,
        WikiMarkdownExtensions.postprocess_tags, 
        sinatra,
        hard_wrap: true, 
        autolink: true, 
        safe_links_only: true,
        escape_html: escape_html)
            
        @engine = Redcarpet::Markdown.new(renderer, options)
      end
  
      def to_html(markdown)
        rendered = @engine.render markdown
        MarkdownFinalizer.process rendered
      end  
    end
  end
end

