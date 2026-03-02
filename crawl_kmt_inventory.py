#!/usr/bin/env python3
"""
KMT Knowledge Base Inventory Crawler
Systematically crawls all KMT categories and builds comprehensive JSON metadata
"""

import requests
import re
import json
from datetime import datetime
from typing import Dict, List, Set
import time

# ASCII-only output (no Unicode)
def print_info(msg):
    print(f"[INFO] {msg}")

def print_success(msg):
    print(f"[SUCCESS] {msg}")

def print_error(msg):
    print(f"[ERROR] {msg}")

def fetch_category_articles(category_id: str, category_name: str) -> Dict:
    """Fetch all articles from a category page"""
    url = f"https://kmt-ogc.service.gc.ca/category/?id={category_id}"
    
    try:
        print_info(f"Fetching {category_name} ({category_id})...")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        html = response.text
        
        # Extract article links with titles
        # Pattern: [Title](url?pid=KA-#####)
        pattern = r'\[([^\]]+)\]\(https://kmt-ogc\.service\.gc\.ca/(?:en/)?knowledgebase/article-latest\?pid=(KA-\d{5})'
        matches = re.findall(pattern, html)
        
        articles = []
        article_ids = set()
        
        for title, pid in matches:
            if pid not in article_ids:  # Avoid duplicates within same category
                articles.append({
                    'pid': pid,
                    'title': title.strip(),
                    'url': f"https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid={pid}&cid={category_id}",
                    'category_id': category_id,
                    'category_name': category_name
                })
                article_ids.add(pid)
        
        print_success(f"  Found {len(articles)} articles in {category_name}")
        
        return {
            'id': category_id,
            'name': category_name,
            'url': url,
            'article_count': len(articles),
            'articles': articles,
            'status': 'success'
        }
        
    except Exception as e:
        print_error(f"  Failed to fetch {category_name}: {str(e)}")
        return {
            'id': category_id,
            'name': category_name,
            'url': url,
            'article_count': 0,
            'articles': [],
            'status': 'error',
            'error': str(e)
        }

def main():
    """Main crawler function"""
    print_info("=" * 60)
    print_info("KMT Knowledge Base Complete Inventory Crawler")
    print_info("=" * 60)
    
    # Define all categories to crawl
    categories_to_crawl = [
        {'id': 'CAT-01912', 'name': 'System Actions', 'parent': None},
        {'id': 'CAT-01913', 'name': 'ITRDS', 'parent': 'CAT-01912'},
        {'id': 'CAT-01496', 'name': 'CPMS', 'parent': 'CAT-01912'},
        {'id': 'CAT-01915', 'name': 'PWS', 'parent': 'CAT-01912'},
        {'id': 'CAT-01931', 'name': 'Appeals', 'parent': 'CAT-01912'},
        {'id': 'CAT-01917', 'name': 'PSCD', 'parent': 'CAT-01912'},
        {'id': 'CAT-01918', 'name': 'SAP', 'parent': 'CAT-01912'},
        {'id': 'CAT-01958', 'name': 'Curam', 'parent': 'CAT-01912'},
        {'id': 'CAT-02016', 'name': 'Persons', 'parent': None},
        {'id': 'CAT-01532', 'name': 'Trending', 'parent': None},
    ]
    
    metadata = {
        'generated': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'source': 'https://kmt-ogc.service.gc.ca/',
        'description': 'Complete KMT Knowledge Base Inventory - All Categories and Articles',
        'language': 'en',
        'categories': [],
        'summary': {
            'total_categories': 0,
            'total_article_instances': 0,
            'total_unique_articles': 0
        }
    }
    
    all_articles: Dict[str, Dict] = {}
    
    # Crawl each category
    for idx, category in enumerate(categories_to_crawl, 1):
        print_info(f"\n[{idx}/{len(categories_to_crawl)}] Processing category...")
        
        category_data = fetch_category_articles(category['id'], category['name'])
        category_data['parent'] = category.get('parent')
        
        metadata['categories'].append(category_data)
        
        # Track unique articles across all categories
        for article in category_data.get('articles', []):
            pid = article['pid']
            if pid not in all_articles:
                all_articles[pid] = {
                    'pid': pid,
                    'title': article['title'],
                    'categories': [category['name']],
                    'first_seen_in': category['name']
                }
            else:
                # Article appears in multiple categories
                all_articles[pid]['categories'].append(category['name'])
        
        # Rate limiting
        time.sleep(0.5)
    
    # Calculate summary statistics
    metadata['summary']['total_categories'] = len(categories_to_crawl)
    metadata['summary']['total_article_instances'] = sum(
        cat['article_count'] for cat in metadata['categories']
    )
    metadata['summary']['total_unique_articles'] = len(all_articles)
    
    # Add unique articles list
    metadata['unique_articles'] = sorted(all_articles.values(), key=lambda x: x['pid'])
    
    # Save to JSON
    output_file = 'KMT-DATABASE-INVENTORY.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    # Display summary
    print_info("\n" + "=" * 60)
    print_info("INVENTORY COMPLETE")
    print_info("=" * 60)
    print_info(f"Total Categories Crawled: {metadata['summary']['total_categories']}")
    print_info(f"Total Article Instances: {metadata['summary']['total_article_instances']}")
    print_info(f"Total Unique Articles: {metadata['summary']['total_unique_articles']}")
    print_success(f"\nJSON metadata saved to: {output_file}")
    
    # Display top categories by article count
    print_info("\nTop Categories by Article Count:")
    sorted_cats = sorted(metadata['categories'], key=lambda x: x['article_count'], reverse=True)
    for cat in sorted_cats[:5]:
        print_info(f"  {cat['name']:20s} {cat['article_count']:3d} articles")
    
    # Display articles that appear in multiple categories
    multi_cat_articles = [a for a in all_articles.values() if len(a['categories']) > 1]
    if multi_cat_articles:
        print_info(f"\nArticles appearing in multiple categories: {len(multi_cat_articles)}")
        for article in multi_cat_articles[:5]:
            print_info(f"  {article['pid']}: {len(article['categories'])} categories")
    
    # Display sample articles
    print_info("\nSample Articles (first 5):")
    for article in list(all_articles.values())[:5]:
        print_info(f"  {article['pid']}: {article['title'][:60]}...")

if __name__ == '__main__':
    main()
