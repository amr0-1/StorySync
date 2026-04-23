import WidgetKit
import SwiftUI

// Shared Theme Colors
let inkVoid = Color(red: 0.071, green: 0.071, blue: 0.078)
let ceramic = Color(red: 0.102, green: 0.102, blue: 0.118)
let brushedSteel = Color(red: 0.173, green: 0.173, blue: 0.196)
let goldSpark = Color(red: 0.831, green: 0.686, blue: 0.216)
let goldLight = Color(red: 0.910, green: 0.831, blue: 0.541)
let textPrimary = Color.white
let textSecondary = Color(red: 0.702, green: 0.702, blue: 0.702)
let textHint = Color(red: 0.4, green: 0.4, blue: 0.4)

// MARK: - Up Next Widget
struct UpNextEntry: TimelineEntry {
    let date: Date
    let mangaTitle: String
    let currentChapter: Int
    let totalChapters: Int?
    let mangaId: String
}

struct UpNextProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpNextEntry {
        UpNextEntry(date: Date(), mangaTitle: "No manga in progress", currentChapter: 0, totalChapters: nil, mangaId: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (UpNextEntry) -> ()) {
        completion(UpNextEntry(date: Date(), mangaTitle: "Loading...", currentChapter: 0, totalChapters: nil, mangaId: ""))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpNextEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.storysync.app")
        let title = sharedDefaults?.string(forKey: "widget_manga_title") ?? "No manga in progress"
        let currentChapter = sharedDefaults?.integer(forKey: "widget_current_chapter") ?? 0
        let totalChapters = sharedDefaults?.object(forKey: "widget_total_chapters") as? Int
        let mangaId = sharedDefaults?.string(forKey: "widget_manga_id") ?? ""
        
        let entry = UpNextEntry(date: Date(), mangaTitle: title, currentChapter: currentChapter, totalChapters: totalChapters, mangaId: mangaId)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct UpNextWidgetEntryView: View {
    var entry: UpNextProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("StorySync")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(goldLight)
                Spacer()
                Text("UP NEXT")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textHint)
            }
            
            // Content
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.mangaTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 2) {
                        Text("Ch. \(entry.currentChapter)")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(goldSpark)
                        if let total = entry.totalChapters, total > 0 {
                            Text("/ \(total)")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(textHint)
                        }
                    }
                }
                Spacer()
                // Increment Button
                Link(destination: URL(string: "storysync://increment?mangaId=\(entry.mangaId)")!) {
                    Text("+1")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.031, green: 0.059, blue: 0))
                        .frame(width: 48, height: 48)
                        .background(goldSpark)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Material.ultraThin
        }
    }
}

struct UpNextWidget: Widget {
    let kind: String = "UpNextWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpNextProvider()) { entry in
            UpNextWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up Next")
        .description("Continue reading your most recent manga.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


// MARK: - Heatmap Widget
struct HeatmapEntry: TimelineEntry {
    let date: Date
    let heatmapData: [Int]
    let heatmapDates: [String]
}

struct HeatmapProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeatmapEntry {
        HeatmapEntry(date: Date(), heatmapData: Array(repeating: 0, count: 35), heatmapDates: Array(repeating: "", count: 35))
    }

    func getSnapshot(in context: Context, completion: @escaping (HeatmapEntry) -> ()) {
        completion(HeatmapEntry(date: Date(), heatmapData: Array(repeating: 0, count: 35), heatmapDates: Array(repeating: "", count: 35)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeatmapEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.storysync.app")
        let heatmapDataStr = sharedDefaults?.string(forKey: "widget_heatmap_data") ?? "[]"
        let heatmapDatesStr = sharedDefaults?.string(forKey: "widget_heatmap_dates") ?? "[]"

        var heatmapValues: [Int] = Array(repeating: 0, count: 35)
        var datesValues: [String] = Array(repeating: "", count: 35)

        if let dataInfo = heatmapDataStr.data(using: .utf8), let parsed = try? JSONDecoder().decode([Int].self, from: dataInfo) {
            heatmapValues = parsed
        }
        if let datesInfo = heatmapDatesStr.data(using: .utf8), let parsedDates = try? JSONDecoder().decode([String].self, from: datesInfo) {
            datesValues = parsedDates
        }

        let entry = HeatmapEntry(date: Date(), heatmapData: heatmapValues, heatmapDates: datesValues)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct HeatmapWidgetEntryView: View {
    var entry: HeatmapProvider.Entry
    
    // We expect 35 cells for 5 rows x 7 days
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("StorySync")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(goldLight)
                Spacer()
                Text("ACTIVITY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(textHint)
            }
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<min(35, entry.heatmapData.count), id: \.self) { i in
                    let val = entry.heatmapData[i]
                    let dateStr = i < entry.heatmapDates.count ? entry.heatmapDates[i] : ""
                    
                    let cell = RoundedRectangle(cornerRadius: 2)
                        .fill(val == 0 ? textPrimary.opacity(0.1) : goldSpark.opacity(val > 2 ? 1.0 : 0.35))
                        .frame(height: 12)
                    
                    if !dateStr.isEmpty {
                        Link(destination: URL(string: "storysync://insights?date=\(dateStr)")!) {
                            cell
                        }
                    } else {
                        cell
                    }
                }
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Material.ultraThin
        }
    }
}

struct HeatmapWidget: Widget {
    let kind: String = "HeatmapWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatmapProvider()) { entry in
            HeatmapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Reading Activity")
        .description("Track your reading heatmap grid.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle
@main
struct StorySyncWidgetBundle: WidgetBundle {
    var body: some WidgetConfiguration {
        UpNextWidget()
        HeatmapWidget()
    }
}