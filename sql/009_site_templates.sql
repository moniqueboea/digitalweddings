-- Site Templates table
-- Stores template metadata so the gallery can be sorted by date added

CREATE TABLE dbo.SiteTemplates (
    template_id     INT IDENTITY(1,1) PRIMARY KEY,
    template_key    NVARCHAR(80)  NOT NULL UNIQUE,   -- matches CFM filename stem
    display_name    NVARCHAR(120) NOT NULL,
    description     NVARCHAR(400) NOT NULL DEFAULT '',
    preview_image   NVARCHAR(400) NOT NULL DEFAULT '',
    color_1         NVARCHAR(20)  NOT NULL DEFAULT '#333333',
    color_2         NVARCHAR(20)  NOT NULL DEFAULT '#888888',
    color_3         NVARCHAR(20)  NOT NULL DEFAULT '#CCCCCC',
    is_active       BIT           NOT NULL DEFAULT 1,
    created_at      DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Original templates (oldest first) ────────────────────────────────────────
INSERT INTO dbo.SiteTemplates (template_key, display_name, description, preview_image, color_1, color_2, color_3, created_at) VALUES
('modern_minimal',   'Modern Minimal',              'Clean lines, bold contrast, and contemporary sans-serif design.',                                        'https://images.unsplash.com/photo-1535428245347-3ab06a1b100a?w=600&h=400&fit=crop', '#1A1A1A', '#FFFFFF', '#C4A265', '2024-01-01'),
('royal_elegance',   'Royal Elegance',              'Deep purples, luxurious textures, and regal styling.',                                                   'https://images.unsplash.com/photo-1594425437587-e75c19ebf332?w=600&h=400&fit=crop', '#4A1A6B', '#F8F0FF', '#D4AF37', '2024-01-02'),
('cultural_heritage','Cultural Heritage',           'Rich patterns, vibrant colors, celebrating African heritage.',                                           'https://images.unsplash.com/photo-1606216836537-eea72a939072?w=600&h=400&fit=crop&crop=top', '#D4AF37', '#1A1A2E', '#E94560', '2024-01-03'),
('christian_sacred', 'Christian - Classic & Sacred','White & ivory with deep navy and gold, cross watermarks and scripture accents.',                        'https://images.unsplash.com/photo-1606216836537-eea72a939072?w=600&h=400&fit=crop', '#FFFFFF', '#1A2744', '#C9A84C', '2024-01-04'),
('editorial_noir',   'Editorial Noir',              'Sophisticated high-contrast black with off-white serif typography.',                                     'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=600&h=400&fit=crop', '#121212', '#F0EDE8', '#333333', '2024-01-05'),
('pride_modern',     'Modern Pride',                'Clean white with a bold full-spectrum rainbow stripe and sharp editorial grid.',                         'https://images.unsplash.com/photo-1535428245347-3ab06a1b100a?w=600&h=400&fit=crop', '#E40303', '#FFED00', '#004DFF', '2024-01-06'),
('romantic_rose',    'Romantic Rose',               'Dusty rose and blush tones with a dramatic center-panel hero and script accents.',                      '/assets/roses-hero.jpeg', '#C4686A', '#F2D6D6', '#6B2D35', '2024-06-01'),
('midnight_rose',    'Midnight Rose',               'Dark and moody with a dramatic floral hero, cream typography, and gold accents.',                       '/assets/dark-roses.jpg',  '#0D0D0D', '#C9A97A', '#F5EFE6', '2024-06-02'),
('midnight_garden',  'Midnight Garden',             'Moody plum florals with oversized centered names and a cinematic dark aesthetic.',                      '/assets/dark-bloom.jpg',  '#0A0608', '#3D1A2E', '#F0EAE2', '2024-06-03'),
('first_light',      'First Light',                 'Soft greige and warm white with fine-art floral photography and minimal serif elegance.',               '/assets/first-light.jpg', '#FAF9F7', '#E8E4DF', '#8C7B6B', '2024-06-04');

-- ── New templates added 2025 ─────────────────────────────────────────────────
INSERT INTO dbo.SiteTemplates (template_key, display_name, description, preview_image, color_1, color_2, color_3, created_at) VALUES
('crimson_garden',   'Crimson Garden',   'Watercolor burgundy florals on white with script names and romantic blush accents.',             '/assets/watercolor-top.jpg',   '#7B2835', '#F5E8E6', '#7A9B6A', '2025-06-20'),
('golden_affair',    'Golden Affair',    'Gold glitter corner accents on white with champagne tones and elegant script names.',            '/assets/gold-corner-top.jpg',  '#C9A242', '#F7F0E3', '#1E1A14', '2025-06-21'),
('indigo_bloom',     'Indigo Bloom',     'Navy watercolor peonies framing a white page with gold accents and elegant typography.',         '/assets/blue-floral-left.jpg', '#1C3166', '#EEF3F9', '#B8922A', '2025-06-22'),
('velvet_peony',     'Velvet Peony',     'Botanical peonies frame a dark navy watercolor hero with gold and rose accents.',               '/assets/peony-top.jpg',        '#7D2235', '#111B2E', '#C4A35A', '2025-06-23'),
('violet_garden',    'Violet Garden',    'Watercolor anemone and succulent florals on white with lavender and teal accents.',             '/assets/violet-floral-top.jpg','#7B5EA7', '#6BBFBF', '#D4809A', '2025-06-23'),
('sage_wreath',      'Sage Wreath',      'Eucalyptus and gold wreath frames couple names on a clean white background.',                   '/assets/sage-wreath.jpg',      '#7A9B82', '#B8922A', '#FAFAF7', '2025-06-24'),
('blush_silk',       'Blush Silk',       'Soft blush chiffon full-bleed hero with rose and deep wine accents.',                          '/assets/blush-silk.jpg',       '#C49090', '#F2DDD8', '#7A3D42', '2025-06-24'),
('rouge_peony',      'Rouge Peony',      'Crimson botanical peonies in opposing corners on a clean white background.',                    '/assets/rouge-peony-1.jpg',    '#8B2035', '#C4707A', '#FAF0EE', '2025-06-25'),
('midnight_peony',   'Midnight Peony',   'Dark moody pink peonies with cream typography on a near-black background.',                    '/assets/midnight-peony.jpg',   '#0A0608', '#C4707A', '#F0EAE2', '2025-06-25');
