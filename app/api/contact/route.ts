import { NextRequest, NextResponse } from "next/server"
import { logger } from "@/lib/logger"
import { prisma } from "@/lib/prisma"

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { name, email, message } = body

    // Validierung
    if (!name || !email || !message) {
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

    // Daten in Datenbank speichern
    await prisma.contact.create({
      data: {
        name,
        email,
        message,
      },
    })

    logger.info("Contact form submission saved to database", { name, email })

    return NextResponse.json(
      { message: "Message received successfully" },
      { status: 200 }
    )
  } catch (error) {
    logger.error("Error processing contact form", error)
    
    // Prisma-spezifische Fehlerbehandlung
    if (error instanceof Error) {
      // Datenbankverbindungsfehler
      if (error.message.includes("P1001") || error.message.includes("connect")) {
        logger.error("Database connection error", error)
        return NextResponse.json(
          { error: "Database connection failed. Please try again later." },
          { status: 503 }
        )
      }
    }

    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    )
  }
}
