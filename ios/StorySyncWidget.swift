// StorySync Widget Extension
// This code would go in the WidgetKit extension target in Xcode

import WidgetKit
import SwiftUI

struct StorySyncEntry: TimelineEntry {
    let date: Date
    let mangaTitle: String
    let currentChapter: Int
    let totalChapters: Int?
    let mangaId: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StorySyncEntry {
        StorySyncEntry(
            date: Date(),
            mangaTitle: "No manga in progress",
            currentChapter: 0,
            totalChapters: nil,
            mangaId: ""
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StorySyncEntry) -> ()) {
        let entry = StorySyncEntry(
            date: Date(),
            mangaTitle: "Loading...",
            currentChapter: 0,
            totalChapters: nil,
            mangaId: ""
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorySyncEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.storysync.app")
        
        let title = sharedDefaults?.string(forKey: "widget_manga_title") ?? "No manga in progress"
        let currentChapter = sharedDefaults?.integer(forKey: "widget_current_chapter") ?? 0
        let totalChapters = sharedDefaults?.object(forKey: "widget_total_chapters") as? Int
        let mangaId = sharedDefaults?.string(forKey: "widget_manga_id") ?? ""

        let entry = StorySyncEntry(
            date: Date(),
            mangaTitle: title,
            currentChapter: currentChapter,
            totalChapters: totalChapters,
            mangaId: mangaId
        )

        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct StorySyncWidgetEntryView: View {
    var entry: Provider.Entry
    
    // Void Ink Theme Colors
    let inkVoid = Color(red: 0.071, green: 0.071, blue: 0.078)
    let ceramic = Color(red: 0.102, green: 0.102, blue: 0.118)
    let brushedSteel = Color(red: 0.173, green: 0.173, blue: 0.196)
    let goldSpark = Color(red: 0.831, green: 0.686, blue: 0.216)
    let goldLight = Color(red: 0.910, green: 0.831, blue: 0.541)
    let textPrimary = Color.white
    let textSecondary = Color(red: 0.702, green: 0.702, blue: 0.702)
    let textHint = Color(red: 0.4, green: 0.4, blue: 0.4)

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
            RoundedRectangle(cornerRadius: 0)
                .fill(inkVoid)
        }
    }
}

@main
struct StorySyncWidget: Widget {
    let kind: String = "StorySyncWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StorySyncWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("StorySync")
        .description("Track your reading progress directly from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    StorySyncWidget()
} timeline: {
    StorySyncEntry(
        date: .now,
        mangaTitle: "One Piece",
        currentChapter: 1089,
        totalChapters: nil,
        mangaId: "abc123"
    )
}