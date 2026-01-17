"use client"

import { useEffect, useRef, useState } from "react"

interface HeroVideoBackgroundProps {
  src: string
  className?: string
}

export default function HeroVideoBackground({ src, className = "" }: HeroVideoBackgroundProps) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const [isLoaded, setIsLoaded] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const video = videoRef.current
    if (!video) return

    const handleLoadedData = () => {
      setIsLoaded(true)
      setIsLoading(false)
      // Smooth fade-in after video data is loaded
      video.play().catch(() => {
        // Fallback wenn autoplay nicht funktioniert
        setIsLoaded(true)
        setIsLoading(false)
      })
    }

    const handleCanPlay = () => {
      setIsLoading(false)
    }

    const handleError = () => {
      setIsLoading(false)
      // Fallback wenn Video nicht geladen werden kann
    }

    video.addEventListener('loadeddata', handleLoadedData, { once: true })
    video.addEventListener('canplay', handleCanPlay, { once: true })
    video.addEventListener('error', handleError, { once: true })

    // Start loading
    video.load()

    return () => {
      video.removeEventListener('loadeddata', handleLoadedData)
      video.removeEventListener('canplay', handleCanPlay)
      video.removeEventListener('error', handleError)
    }
  }, [src])

  return (
    <div className="absolute inset-0 -z-20">
      {/* Loading Spinner */}
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-background/80 z-10">
          <div className="hero-video-loader">
            <div className="hero-video-loader-spinner"></div>
          </div>
        </div>
      )}

      {/* Video */}
      <video
        ref={videoRef}
        autoPlay
        loop
        muted
        playsInline
        preload="metadata"
        className={`h-full w-full object-cover transition-opacity duration-700 ${isLoaded ? 'opacity-100' : 'opacity-0'} ${className}`}
      >
        <source src={src} type="video/mp4" />
      </video>
    </div>
  )
}
