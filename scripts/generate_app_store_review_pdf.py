#!/usr/bin/env python3
"""Generate App Store Review Information PDF for Skin Care AI: Routine Coach."""

from datetime import date
from pathlib import Path

from fpdf import FPDF

OUTPUT = Path(__file__).resolve().parent.parent / "docs" / "App_Store_Review_Information.pdf"


class ReviewPDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font("Helvetica", "I", 8)
            self.set_text_color(100, 100, 100)
            self.cell(0, 8, "Skin Care AI: Routine Coach - App Review Information", align="R")
            self.ln(4)
            self.set_text_color(0, 0, 0)

    def footer(self):
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")

    def section_title(self, num: str, title: str):
        self.ln(4)
        self.set_font("Helvetica", "B", 12)
        self.set_fill_color(240, 245, 250)
        self.set_x(self.l_margin)
        self.multi_cell(self.epw, 8, f"{num}. {title}", fill=True)
        self.ln(2)

    def body(self, text: str):
        self.set_x(self.l_margin)
        self.set_font("Helvetica", "", 10)
        self.multi_cell(self.epw, 5, text)
        self.ln(1)

    def bullet(self, text: str):
        self.set_x(self.l_margin)
        self.set_font("Helvetica", "", 10)
        self.multi_cell(self.epw, 5, f"- {text}")


def build_pdf() -> None:
    pdf = ReviewPDF()
    pdf.set_auto_page_break(auto=True, margin=20)
    pdf.add_page()

    # Title page
    pdf.set_font("Helvetica", "B", 22)
    pdf.ln(30)
    pdf.cell(0, 12, "App Store Review Information", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(4)
    pdf.set_font("Helvetica", "B", 16)
    pdf.cell(0, 10, "Skin Care AI: Routine Coach", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)
    pdf.set_font("Helvetica", "", 11)
    pdf.cell(0, 7, "Prepared for Apple App Review", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 7, f"Document date: {date.today().strftime('%B %d, %Y')}", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(12)
    pdf.set_font("Helvetica", "", 10)
    meta = [
        "Bundle ID: com.skincare.routineai",
        "Version: 1.0.0 (Build 3)",
        "Platform: iOS",
        "Category: Health & Fitness / Lifestyle (wellness)",
    ]
    for line in meta:
        pdf.cell(0, 6, line, align="C", new_x="LMARGIN", new_y="NEXT")

    pdf.add_page()

    pdf.section_title("2", "Devices and operating systems tested before submission")
    pdf.body(
        "The app was tested on the following devices and OS versions prior to "
        "submission for App Review:"
    )
    devices = [
        "iPhone 15 Pro - iOS 18.x (primary device; full feature and IAP sandbox testing)",
        "iPhone 14 - iOS 17.x (layout, onboarding, navigation)",
        "iPhone SE 3rd gen - iOS 17.x (smaller screen layout)",
        "iOS Simulator - iOS 18.x (Xcode; UI flows and onboarding)",
        "iOS Simulator - iOS 17.x (backward compatibility spot-check)",
    ]
    for d in devices:
        pdf.bullet(d)
    pdf.ln(2)
    pdf.body(
        "Build environment: Flutter 3.x, Xcode (current stable). Release and "
        "TestFlight builds were used for In-App Purchase testing with a Sandbox "
        "Apple ID. Replace device rows above with your exact hardware if different."
    )

    pdf.section_title(
        "3",
        "App purpose, target audience, problem solved, and value provided",
    )
    pdf.body("Purpose:")
    pdf.body(
        "Skin Care AI: Routine Coach helps users build and maintain a consistent "
        "skincare routine through habit tracking, morning and night routine "
        "checklists, progress photos, and AI-powered wellness coaching. The app "
        "does not provide medical diagnosis or treatment."
    )
    pdf.body("Target audience:")
    pdf.body(
        "Adults interested in skincare consistency, including beginners establishing "
        "a routine and users tracking concerns such as breakouts, uneven tone, "
        "dryness, sensitivity, or oil control over time."
    )
    pdf.body("Problem it solves:")
    pdf.body(
        "Many users struggle to stay consistent with cleansing, SPF, hydration, and "
        "product routines, and lack a simple way to visualize progress over weeks. "
        "The app consolidates routine steps, daily habits, and photo check-ins in "
        "one focused experience."
    )
    pdf.body("Value provided:")
    for v in [
        "Personalized onboarding and home dashboard insights",
        "Morning and night routine planner with check-offs",
        "Daily habit tracking for skin-friendly behaviors",
        "Progress photo timeline and AI-assisted observations",
        "AI coach chat for routine and product consistency questions",
        "Optional Premium: unlimited uploads, full history, advanced insights",
    ]:
        pdf.bullet(v)
    pdf.body(
        "Disclaimer: For general wellness and education only. Not a substitute for "
        "professional medical advice, diagnosis, or treatment."
    )

    pdf.add_page()
    pdf.section_title(
        "4",
        "Setup instructions and access to main features (login, credentials, samples)",
    )
    pdf.body("Login and account requirements:")
    pdf.body(
        "No login or user account is required. No test credentials are needed. "
        "App data is stored locally on the device using on-device preferences."
    )
    pdf.body("Reviewer setup steps:")
    steps = [
        "Install the submitted build from App Review or TestFlight.",
        "On first launch, complete the onboarding questionnaire (tap Continue through all screens, then Start my routine).",
        "When prompted, allow Camera and/or Photo Library access for progress photos.",
        "Ensure an active internet connection for AI features (see Section 5).",
    ]
    for i, s in enumerate(steps, 1):
        pdf.bullet(f"{i}. {s}")

    pdf.body("Main features - how to access:")
    features = [
        "Home dashboard: Bottom tab Home - routine score and insights (full metrics require Premium).",
        "Routine plan: Tab Routine - morning/night skincare steps.",
        "Progress photos: Center + button - choose camera or photo library; AI analysis runs after upload.",
        "Progress history: Tab Progress - timeline of check-ins.",
        "Daily habits: Tab Habits.",
        "AI coach: Accessible from the in-app coach flow after onboarding.",
        "Settings / dark mode: Settings icon on Home tab.",
        "Premium upgrade: Settings > Upgrade to Premium, or Progress tab > Unlock Premium, or attempt a second progress upload on the free plan.",
    ]
    for f in features:
        pdf.bullet(f)

    pdf.body("In-App Purchase testing (Sandbox):")
    iap_steps = [
        "On the test device: Settings > App Store > Sandbox Account - sign in with a Sandbox tester.",
        "Open the app > Settings > Upgrade to Premium (or Progress > Unlock Premium).",
        "Purchase Monthly, Yearly, or Lifetime; verify Restore purchases.",
    ]
    for s in iap_steps:
        pdf.bullet(s)

    pdf.body("Product identifiers:")
    pdf.bullet("com.skincare.routineai.premium.monthly (auto-renewable subscription)")
    pdf.bullet("com.skincare.routineai.premium.yearly (auto-renewable subscription)")
    pdf.bullet("com.skincare.routineai.premium.lifetime (non-consumable)")

    pdf.body(
        "Sample files: Not required. Reviewers may use any appropriate photo from "
        "the device camera roll or simulator library."
    )
    pdf.body(
        "Free vs Premium: Free plan allows one progress upload per rolling 7-day "
        "window and limited timeline/history. Premium unlocks unlimited uploads, "
        "full history, and full home insights."
    )

    pdf.add_page()
    pdf.section_title(
        "5",
        "External services, tools, and platforms (core functionality)",
    )
    pdf.body("The app uses the following third-party services:")
    services = [
        "OpenRouter (https://openrouter.ai/api/v1/chat/completions) - AI chat coach, personalized content generation, and photo analysis. Data sent when user triggers AI: chat messages, onboarding context, and progress photos (base64-encoded images). API authentication via server-side/developer-configured API key in the app build.",
        "Apple In-App Purchase (StoreKit) - Monthly and yearly auto-renewable subscriptions and lifetime non-consumable unlock. Payments processed entirely by Apple.",
        "Apple Camera and Photo Library - User-initiated progress photo capture and selection. Processed on-device; only sent to AI when user runs analysis.",
        "Google Fonts (via google_fonts package) - UI typography; standard font delivery.",
        "Default AI model (configurable): google/gemma-4-31b-it via OpenRouter.",
    ]
    for s in services:
        pdf.bullet(s)
    pdf.body(
        "Not used in current version: Firebase, custom backend authentication, "
        "Stripe, advertising SDKs, or third-party analytics SDKs."
    )
    pdf.body("Legal links in app:")
    pdf.bullet("Terms of Service: https://www.writecream.com/terms-of-service/")
    pdf.bullet("Apple Licensed Application EULA (linked from premium paywall)")

    pdf.section_title(
        "6",
        "Regional differences in features or content",
    )
    pdf.body(
        "The app functions consistently across all App Store regions where it is "
        "distributed. There are no region-specific feature gates, geo-fenced "
        "content modules, or territory-only UI variations."
    )
    pdf.body(
        "Subscription and lifetime pricing follow Apple's regional App Store pricing. "
        "In-app fallback display prices (when store prices are loading): Monthly "
        "$4.99, Yearly $29.99, Lifetime $59.99 USD equivalent tiers."
    )
    pdf.body(
        "AI responses are primarily in English; the chat coach may respond in other "
        "languages if the user writes in them. No region-specific medical or legal "
        "content variants are included."
    )
    pdf.body("Confirmation: Feature parity across all supported territories.")

    pdf.add_page()
    pdf.section_title(
        "7",
        "Regulated industry, protected content, and authorization",
    )
    pdf.body("Industry classification:")
    pdf.body(
        "General wellness and skincare routine tracking. The app is NOT a medical "
        "device and does NOT provide medical diagnosis, prescription, or treatment. "
        "Copy and AI system prompts explicitly state the app is not a doctor and "
        "users should consult qualified healthcare professionals for medical concerns."
    )
    pdf.body("Authorization and credentials:")
    auth = [
        "No FDA clearance or medical-device registration - app does not claim regulated medical functionality.",
        "No licensed clinical diagnostic content - coaching and educational routine guidance only.",
        "AI content is generated via OpenRouter using configured models; no redistribution of proprietary clinical databases or copyrighted medical guides.",
        "User-submitted photos only; no stock medical imagery requiring separate licensing.",
        "Developer Terms of Service linked in-app (Writecream URL above; update to your entity before production if needed).",
        "Privacy Policy URL: [REQUIRED - insert your live privacy policy URL before submission]",
        "Support URL: [Insert your support page or contact URL before submission]",
    ]
    for a in auth:
        pdf.bullet(a)
    pdf.body(
        "If additional clarification is needed: This app is comparable to lifestyle, "
        "habit, and beauty journaling applications with explicit non-medical "
        "disclaimers in AI prompts and photo analysis flows."
    )

    pdf.ln(6)
    pdf.set_font("Helvetica", "B", 10)
    pdf.body("Quick reference - Notes for Review (summary):")
    pdf.set_font("Helvetica", "", 9)
    pdf.set_x(pdf.l_margin)
    pdf.multi_cell(
        pdf.epw,
        5,
        "No login required. Complete onboarding, then use + to add a progress photo "
        "(allow Camera/Photos). Premium: Sandbox Apple ID > Settings > Upgrade to "
        "Premium. Product IDs: com.skincare.routineai.premium.monthly, .yearly, "
        ".lifetime. AI requires network (OpenRouter). Not medical advice. Same "
        "features in all regions. Update Privacy Policy and Support URLs before submit.",
    )

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    pdf.output(str(OUTPUT))
    print(f"Generated: {OUTPUT}")


if __name__ == "__main__":
    build_pdf()
