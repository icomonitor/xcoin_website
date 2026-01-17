import { NextRequest, NextResponse } from "next/server"
import { logger } from "@/lib/logger"

// TODO: Später mit Datenbank verbinden
// - Applications in Datenbank speichern
// - E-Mail-Benachrichtigung senden
// - Validierung erweitern
// - Rate Limiting hinzufügen
// - Duplicate Check (bereits existierende Application prüfen)

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { name, email, serverSpecs, connectionSpeed, location } = body

    // Validierung
    if (!name || !email || !serverSpecs || !connectionSpeed || !location) {
      return NextResponse.json(
        { error: "All fields are required" },
        { status: 400 }
      )
    }

    // Email-Validierung
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: "Invalid email address" },
        { status: 400 }
      )
    }

    // TODO: Hier später:
    // 1. Prüfen ob bereits eine Application mit dieser Email existiert (pending)
    //    const existingApplication = await prisma.validatorApplication.findFirst({
    //      where: {
    //        email: email,
    //        status: "pending"
    //      }
    //    })
    //    if (existingApplication) {
    //      return NextResponse.json(
    //        { error: "You already have a pending application" },
    //        { status: 400 }
    //      )
    //    }
    //
    // 2. Daten in Datenbank speichern
    //    await prisma.validatorApplication.create({
    //      data: {
    //        name,
    //        email,
    //        serverSpecs,
    //        connectionSpeed,
    //        location,
    //        status: "pending"
    //      }
    //    })
    //
    // 3. E-Mail senden (z.B. mit Nodemailer, SendGrid, Resend)
    //    await resend.emails.send({
    //      from: 'validators@xcoin.ws',
    //      to: 'info@xcoin.ws',
    //      subject: `New Validator Application from ${name}`,
    //      html: `
    //        <p><strong>Name:</strong> ${name}</p>
    //        <p><strong>Email:</strong> ${email}</p>
    //        <p><strong>Server Specs:</strong> ${serverSpecs}</p>
    //        <p><strong>Connection Speed:</strong> ${connectionSpeed}</p>
    //        <p><strong>Location:</strong> ${location}</p>
    //      `
    //    })
    //
    // 4. Optional: Captcha-Validierung
    //    const captchaValid = await validateCaptcha(captchaToken)
    //    if (!captchaValid) {
    //      return NextResponse.json({ error: "Invalid captcha" }, { status: 400 })
    //    }
    //
    // 5. Optional: Rate Limiting (z.B. mit @upstash/ratelimit)
    //    const rateLimit = await ratelimit.limit(identifier)
    //    if (!rateLimit.success) {
    //      return NextResponse.json({ error: "Too many requests" }, { status: 429 })
    //    }

    // Logging für jetzt (später durch Datenbank ersetzen)
    logger.info("Validator application submission", { 
      name, 
      email, 
      serverSpecs, 
      connectionSpeed, 
      location 
    })

    return NextResponse.json(
      { message: "Application submitted successfully" },
      { status: 200 }
    )
  } catch (error) {
    logger.error("Error processing validator application", error)
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    )
  }
}
