// Listen for messages from background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('[Octarine Content] Received message:', request);
  if (request.action === 'extractContent') {
    console.log('[Octarine Content] Extracting content...');
    extractPageContent().then(result => {
      console.log('[Octarine Content] Extraction result:', result);
      sendResponse(result);
    });
    return true; // Will respond asynchronously
  }
});

async function extractPageContent() {
  try {
    // Clone the document to avoid modifying the original
    const documentClone = document.cloneNode(true);
    
    // Use Readability to extract the main content
    const reader = new Readability(documentClone);
    const article = reader.parse();
    
    if (!article) {
      return { error: 'Could not extract article content' };
    }
    
    // Extract metadata
    const metadata = extractMetadata();
    
    // Convert to markdown using Turndown
    const turndownService = new TurndownService({
      headingStyle: 'atx',
      codeBlockStyle: 'fenced',
      bulletListMarker: '-',
      emDelimiter: '*',
      strongDelimiter: '**'
    });
    
    // Add custom rules for better markdown conversion
    addCustomTurndownRules(turndownService);
    
    // Convert the content to markdown
    const markdown = turndownService.turndown(article.content);
    
    // Prepare the data to send
    const data = {
      type: 'clip',
      content: markdown,
      metadata: {
        title: article.title || metadata.title || document.title,
        url: window.location.href,
        author: article.byline || metadata.author,
        keywords: metadata.keywords,
        date: metadata.publishedDate || new Date().toISOString(),
        excerpt: article.excerpt || metadata.description
      }
    };
    
    return { data };
  } catch (error) {
    console.error('Error extracting content:', error);
    return { error: error.message };
  }
}

function extractMetadata() {
  const metadata = {
    title: document.title,
    author: null,
    keywords: [],
    description: null,
    publishedDate: null
  };
  
  // Extract author
  const authorMeta = document.querySelector('meta[name="author"]') || 
                     document.querySelector('meta[property="article:author"]');
  if (authorMeta) {
    metadata.author = authorMeta.content;
  }
  
  // Extract keywords
  const keywordsMeta = document.querySelector('meta[name="keywords"]');
  if (keywordsMeta && keywordsMeta.content) {
    metadata.keywords = keywordsMeta.content.split(',').map(k => k.trim()).filter(k => k);
  }
  
  // Extract description
  const descriptionMeta = document.querySelector('meta[name="description"]') || 
                          document.querySelector('meta[property="og:description"]');
  if (descriptionMeta) {
    metadata.description = descriptionMeta.content;
  }
  
  // Extract published date
  const dateMeta = document.querySelector('meta[property="article:published_time"]') ||
                   document.querySelector('meta[name="publish_date"]') ||
                   document.querySelector('time[datetime]');
  if (dateMeta) {
    metadata.publishedDate = dateMeta.content || dateMeta.getAttribute('datetime');
  }
  
  // Try to extract from JSON-LD
  const jsonLd = document.querySelector('script[type="application/ld+json"]');
  if (jsonLd) {
    try {
      const data = JSON.parse(jsonLd.textContent);
      if (data['@type'] === 'Article' || data['@type'] === 'NewsArticle' || data['@type'] === 'BlogPosting') {
        metadata.author = metadata.author || data.author?.name || data.author;
        metadata.publishedDate = metadata.publishedDate || data.datePublished;
        metadata.keywords = metadata.keywords.length ? metadata.keywords : (data.keywords || []);
      }
    } catch (e) {
      console.warn('Failed to parse JSON-LD:', e);
    }
  }
  
  return metadata;
}

function addCustomTurndownRules(turndownService) {
  // Preserve code language in fenced code blocks
  turndownService.addRule('fencedCodeBlock', {
    filter: function (node, options) {
      return (
        options.codeBlockStyle === 'fenced' &&
        node.nodeName === 'PRE' &&
        node.firstChild &&
        node.firstChild.nodeName === 'CODE'
      );
    },
    replacement: function (content, node, options) {
      const className = node.firstChild.getAttribute('class') || '';
      const language = (className.match(/language-(\S+)/) || [null, ''])[1];
      const code = node.firstChild.textContent;
      
      return (
        '\n\n```' + language + '\n' +
        code +
        '\n```\n\n'
      );
    }
  });
  
  // Better handling of images with captions
  turndownService.addRule('figure', {
    filter: 'figure',
    replacement: function (content, node) {
      const img = node.querySelector('img');
      const caption = node.querySelector('figcaption');
      
      if (img) {
        const alt = img.getAttribute('alt') || '';
        const src = img.getAttribute('src') || '';
        const title = img.getAttribute('title') || '';
        
        let markdown = `![${alt}](${src}`;
        if (title) {
          markdown += ` "${title}"`;
        }
        markdown += ')';
        
        if (caption) {
          markdown += '\n*' + caption.textContent.trim() + '*';
        }
        
        return '\n\n' + markdown + '\n\n';
      }
      
      return content;
    }
  });
}