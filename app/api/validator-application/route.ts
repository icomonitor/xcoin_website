import { NextRequest, NextResponse } from "next/server"
import { logger } from "@/lib/logger"
import { prisma } from "@/lib/prisma"

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

    // Prüfen ob bereits eine Application mit dieser Email existiert (pending)
    const existingApplication = await prisma.validatorApplication.findFirst({
      where: {
        email: email,
        status: "pending",
      },
    })

    if (existingApplication) {
      return NextResponse.json(
        { error: "You already have a pending application" },
        { status: 400 }
      )
    }

    // Daten in Datenbank speichern
    await prisma.validatorApplication.create({
      data: {
        name,
        email,
        serverSpecs,
        connectionSpeed,
        location,
        status: "pending",
      },
    })

    logger.info("Validator application saved to database", {
      name,
      email,
      serverSpecs,
      connectionSpeed,
      location,
    })

    return NextResponse.json(
      { message: "Application submitted successfully" },
      { status: 200 }
    )
  } catch (error) {
    logger.error("Error processing validator application", error)

    // Prisma-spezifische Fehlerbehandlung
    if (error instanceof Error) {
      // Duplicate entry error (unique constraint)
      if (error.message.includes("Unique constraint") || error.message.includes("P2002")) {
        return NextResponse.json(
          { error: "You already have an application with this email address" },
          { status: 400 }
        )
      }

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
